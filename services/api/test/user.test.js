import supertest from 'supertest';
import { describe, expect, it } from "vitest";
import { faker } from '@faker-js/faker';

import server from '../index.js';
const request = supertest(server);

const _DEFAULT_USER_ = {
  id: "f6cb6e9e-7e19-485c-a4b2-fc10128e4b71",
  email: "user@music.room",
  password: "123",
};

describe("GET users/:user_id", () => {
  it("Return user info", async() => {
    const req = await request.get(
      `/users/${_DEFAULT_USER_.id}`
    );
    expect(req.status).toEqual(200);
    expect(req.body.email).toEqual(_DEFAULT_USER_.email)
    expect(req.body.id).toEqual(_DEFAULT_USER_.id)
  });
  it("User does not exist", async() => {
    const req = await request.get(
      "/users/93eab5fd-fe33-4f1d-92bf-48c00970f772"
    );
    expect(req.status).toEqual(400);
    expect(req.body).toEqual({ error: "Unknow user" })
  });
  it("User id is not UUID format", async() => {
    const req = await request.get(
      "/users/not-uuid-format"
    );
    expect(req.status).toEqual(400);
    expect(req.body).toEqual({ error: "User_id is not uuid format" })
  });
});

describe("User login with email", () => {
  it("test that user can login", async () => {
    const res = await request.post(
      "/users/email/signin"
    )
    .type('form')
    .send({
      email: _DEFAULT_USER_.email,
      password: _DEFAULT_USER_.password,
    });
    expect(res.status).toEqual(200);
    expect(res.type).toEqual(expect.stringContaining("json"));
    expect(res.body.email).toEqual(_DEFAULT_USER_.email)
    expect(res.body.id).toEqual(_DEFAULT_USER_.id)
    expect(res.body.token).toBeDefined();
  });

  it("Email does not exist", async () => {
    const res = await request.post(
      "/users/email/signin"
    )
    .type('form')
    .send({
        email: "fake@email.com",
        password: "wrong pass"
    });
    expect(res.status).toEqual(400);
    expect(res.type).toEqual(expect.stringContaining("json"));
    expect(res.body).toEqual({ error: "Unknow email" })
  });
  it("Email is not sent", async () => {
    const res = await request.post(
      "/users/email/signin"
    ).send();
    expect(res.status).toEqual(400);
    expect(res.type).toEqual(expect.stringContaining("json"));
    expect(res.body).toEqual({ error: "Missing argument: email" })
  });
});

describe("User signup with email", () => {
  const email = faker.internet.email();
  it("test that user can signup", async () => {
    const res = await request.post(
      "/users/email/signup"
    )
    .type('form')
    .send({
        email: email,
        password: "pass",
    });
    expect(res.status).toEqual(201);
    expect(res.type).toEqual(expect.stringContaining("json"));
    expect(res.body.email).toEqual(email);
    expect(res.body.token).toBeDefined();
  });
  it("Email already exist", async () => {
    const res = await request.post(
      "/users/email/signup"
    )
    .type('form')
    .send({
        email: _DEFAULT_USER_.email,
        password: "pass",
    });
    expect(res.status).toEqual(400);
    expect(res.type).toEqual(expect.stringContaining("json"));
    expect(res.body).toEqual({ error: "User already exist" })
  });
  it("Missing argument email", async () => {
    const res = await request.post(
      "/users/email/signup"
    ).send();
    expect(res.status).toEqual(400);
    expect(res.type).toEqual(expect.stringContaining("json"));
    expect(res.body).toEqual({ error: "Missing argument: email" })
  });
  it("Missing argument password", async () => {
    const res = await request.post(
      "/users/email/signup"
    ).send(`email=${email}`);
    expect(res.status).toEqual(400);
    expect(res.type).toEqual(expect.stringContaining("json"));
    expect(res.body).toEqual({ error: "Missing argument: password" })
  });
});
