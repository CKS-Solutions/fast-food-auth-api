package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/cognitoidentityprovider"
	"github.com/aws/aws-sdk-go-v2/service/cognitoidentityprovider/types"

	"github.com/golang-jwt/jwt/v5"
)

type authRequest struct {
	CPF string `json:"cpf"`
}

type errorBody struct {
	Error   string `json:"error"`
	Code    string `json:"code"`
	Details string `json:"details,omitempty"`
}

type successBody struct {
	Message    string            `json:"message"`
	Username   string            `json:"username"`
	CPF        string            `json:"cpf"`
	Attributes map[string]string `json:"attributes"`
	Token      string            `json:"token"`
	ExpiresIn  string            `json:"expiresIn"`
}

func corsHeaders() map[string]string {
	return map[string]string{
		"Content-Type":                 "application/json",
		"Access-Control-Allow-Origin":  "*",
		"Access-Control-Allow-Headers": "Content-Type",
		"Access-Control-Allow-Methods": "POST, OPTIONS",
	}
}

func attributeMap(attrs []types.AttributeType) map[string]string {
	out := make(map[string]string, len(attrs))
	for _, a := range attrs {
		var name, val string
		if a.Name != nil {
			name = *a.Name
		}
		if a.Value != nil {
			val = *a.Value
		}
		if name != "" {
			out[name] = val
		}
	}
	return out
}

func handler(ctx context.Context, event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	h := corsHeaders()

	// CORS preflight
	if event.HTTPMethod == http.MethodOptions {
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusOK,
			Headers:    h,
			Body:       `{"message":"CORS preflight"}`,
		}, nil
	}

	// Parse body
	var req authRequest
	if err := json.Unmarshal([]byte(event.Body), &req); err != nil {
		b, _ := json.Marshal(errorBody{
			Error:   "Invalid request body",
			Code:    "INVALID_BODY",
			Details: err.Error(),
		})
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusBadRequest,
			Headers:    h,
			Body:       string(b),
		}, nil
	}

	if req.CPF == "" {
		b, _ := json.Marshal(errorBody{
			Error: "CPF é obrigatório.",
			Code:  "MISSING_CPF",
		})
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusBadRequest,
			Headers:    h,
			Body:       string(b),
		}, nil
	}

	userPoolID := os.Getenv("COGNITO_USER_POOL_ID")
	if userPoolID == "" {
		b, _ := json.Marshal(errorBody{
			Error:   "Configuração do servidor inválida.",
			Code:    "SERVER_CONFIG_ERROR",
			Details: "COGNITO_USER_POOL_ID is not set",
		})
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusInternalServerError,
			Headers:    h,
			Body:       string(b),
		}, nil
	}

	// AWS SDK config (region via env or default chain)
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		b, _ := json.Marshal(errorBody{
			Error:   "Erro ao carregar configuração AWS.",
			Code:    "AWS_CONFIG_ERROR",
			Details: err.Error(),
		})
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusInternalServerError,
			Headers:    h,
			Body:       string(b),
		}, nil
	}

	client := cognitoidentityprovider.NewFromConfig(cfg)

	input := &cognitoidentityprovider.ListUsersInput{
		UserPoolId: aws.String(userPoolID),
		Filter:     aws.String(fmt.Sprintf(`preferred_username = "%s"`, req.CPF)),
		Limit:      aws.Int32(1),
	}

	out, err := client.ListUsers(ctx, input)
	if err != nil {
		b, _ := json.Marshal(errorBody{
			Error:   "Falha ao buscar usuário.",
			Code:    "COGNITO_LIST_USERS_FAILED",
			Details: err.Error(),
		})
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusInternalServerError,
			Headers:    h,
			Body:       string(b),
		}, nil
	}

	if len(out.Users) == 0 {
		b, _ := json.Marshal(errorBody{
			Error: "CPF não encontrado no sistema.",
			Code:  "USER_NOT_FOUND",
		})
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusNotFound,
			Headers:    h,
			Body:       string(b),
		}, nil
	}

	user := out.Users[0]
	signed, err := generateToken(user, req.CPF)

	if err != nil {
		b, _ := json.Marshal(errorBody{
			Error:   "Erro ao gerar token.",
			Code:    "JWT_SIGN_ERROR",
			Details: err.Error(),
		})
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusInternalServerError,
			Headers:    h,
			Body:       string(b),
		}, nil
	}

	resp := successBody{
		Message:    "Authentication successful! JWT token generated.",
		Username:   aws.ToString(user.Username),
		CPF:        req.CPF,
		Attributes: attributeMap(user.Attributes),
		Token:      signed,
		ExpiresIn:  "24h",
	}
	body, _ := json.Marshal(resp)

	return events.APIGatewayProxyResponse{
		StatusCode: http.StatusOK,
		Headers:    h,
		Body:       string(body),
	}, nil
}

func generateToken(user types.UserType, cpf string) (string, error) {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		secret = "your-secret-key"
	}

	now := time.Now()
	claims := jwt.MapClaims{
		"sub": aws.ToString(user.Username),
		"cpf": cpf,
		"iat": now.Unix(),
		"exp": now.Add(24 * time.Hour).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString([]byte(secret))

	return signed, err
}

func main() {
	lambda.Start(handler)
}
