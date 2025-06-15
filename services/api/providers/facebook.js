export const checkFacebokToken = async(token) => {
  try {
    const req = await fetch(
      `https://graph.facebook.com/me?fields=id,email&access_token=${token}`,
    );
    const data = await req.json();
    return ({
      user_id: data.id,
      email: data.email,
    });
  } catch (e) {
    console.error(e);
    return (null);
  }
};
