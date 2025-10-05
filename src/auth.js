exports.handler = async (event) => {
  console.log("Event Update:", JSON.stringify(event, null, 2));

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "Content-Type",
      "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
    },
    body: JSON.stringify({
      message: "Hello from Fast Food Auth API!",
      timestamp: new Date().toISOString(),
      path: event.path,
      method: event.httpMethod,
    }),
  };
};
