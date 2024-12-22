import supertest from 'supertest';
import { describe, expect, it } from "vitest";

import server from '../index.js';
const request = supertest(server);

const _DEFAULT_USER_ = {
  id: "f6cb6e9e-7e19-485c-a4b2-fc10128e4b71",
  email: "user@music.room",
};
const _API_URL_ = "http://localhost:5051";

describe("User login", () => {
  it("test that user can login", async () => {
    const res = await request.post(
      "/users/email/signin"
    ).send(`email=${_DEFAULT_USER_.email}`);
    expect(res.status).toEqual(200);
    expect(res.type).toEqual(expect.stringContaining("json"));
    expect(res.body).toEqual(_DEFAULT_USER_)
  });
});
