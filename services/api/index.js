import express from "express";

const app = express();
const port = process.env.port || 5001;

app.get("/up", (req, res) => {
  res.status(200).send({
    status: "OK",
  });
});

app.listen(port, () => {
  console.log(`API running on ${port}`)
});
