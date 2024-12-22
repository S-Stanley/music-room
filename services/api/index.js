import express from "express";
import { PrismaClient } from '@prisma/client'

const app = express();
const port = process.env.port || 5001;

const prisma = new PrismaClient();

app.use(express.urlencoded({extended: false}));

app.get("/up", (req, res) => {
  res.status(200).send({
    status: "OK",
  });
});

app.post("/users/email/signin", async(req, res) => {
  console.info("User trying to login with email");
  try {
    if (!req.body?.email){
      return res.status(400).json({
        error: "missing argument: email"
      })
    };
    const user = await prisma.user.findUnique({
      where: {
        email: req.body?.email,
      }
    });
    if (!user){
      return res.status(400).json({
        error: "Unknow email"
      })
    }
    return res.status(200).json({
      id: user?.id,
      email: user?.email,
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "server error"
    });
  }
});

app.listen(port, () => {
  console.info(`API running on ${port}`)
});

export default app;
