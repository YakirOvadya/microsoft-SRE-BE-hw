const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.json({
    status: "running",
    message: "Hello Microsoft - from Service B",
  });
});

const PORT = process.env.PORT || 3002;
app.listen(PORT, () => {
  console.log(`Service B running & listening on port ${PORT}`);
});
