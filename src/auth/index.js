const {
  CognitoIdentityProviderClient,
  ListUsersCommand,
} = require("@aws-sdk/client-cognito-identity-provider");
const jwt = require("jsonwebtoken");

const client = new CognitoIdentityProviderClient({
  region: process.env.AWS_REGION || "us-east-1",
});

exports.handler = async (event) => {
  const headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };

  console.log("New version of the auth lambda");

  if (event.httpMethod === "OPTIONS") {
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ message: "CORS preflight" }),
    };
  }

  try {
    const body = JSON.parse(event.body || "{}");
    const { cpf } = body;

    if (!cpf) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({
          error: "CPF é obrigatório.",
          code: "MISSING_CPF",
        }),
      };
    }

    const userPoolId = process.env.COGNITO_USER_POOL_ID;
    if (!userPoolId) {
      console.error("COGNITO_USER_POOL_ID não configurado");
      return {
        statusCode: 500,
        headers,
        body: JSON.stringify({
          error: "Configuração do servidor inválida.",
          code: "SERVER_CONFIG_ERROR",
        }),
      };
    }

    const searchParams = {
      UserPoolId: userPoolId,
      Filter: `preferred_username = "${cpf}"`,
      Limit: 1,
    };

    console.log("Buscando usuário com parâmetros:", searchParams);

    const searchCommand = new ListUsersCommand(searchParams);
    const searchResponse = await client.send(searchCommand);

    if (!searchResponse.Users || searchResponse.Users.length === 0) {
      return {
        statusCode: 404,
        headers,
        body: JSON.stringify({
          error: "CPF não encontrado no sistema.",
          code: "USER_NOT_FOUND",
        }),
      };
    }

    const user = searchResponse.Users[0];
    console.log("Usuário encontrado:", user.Username);

    try {
      const jwtSecret = process.env.JWT_SECRET || "your-secret-key";

      const jwtPayload = {
        sub: user.Username,
        cpf: cpf,
        iat: Math.floor(Date.now() / 1000),
        exp: Math.floor(Date.now() / 1000) + 24 * 60 * 60, // 24 horas
      };

      const jwtToken = jwt.sign(jwtPayload, jwtSecret, { algorithm: "HS256" });

      console.log("Token JWT gerado com sucesso");

      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
          message: "Autenticação bem-sucedida! Token JWT gerado.",
          username: user.Username,
          cpf: cpf,
          attributes: user.Attributes,
          token: jwtToken,
          expiresIn: "24h",
        }),
      };
    } catch (tokenError) {
      console.error("Erro ao gerar token:", tokenError);
      throw tokenError;
    }
  } catch (error) {
    console.error("Erro ao processar autenticação:", error);

    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({
        error: "Erro interno no servidor.",
        code: "INTERNAL_SERVER_ERROR",
        details:
          process.env.NODE_ENV === "development" ? error.message : undefined,
      }),
    };
  }
};
