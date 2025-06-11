export const checkFacebokToken = async(token) => {
  try {
    const req = await fetch(
      `https://graph.facebook.com/me?access_token=${token}`,
      {
        method: "POST"
      }
    );
    console.log(req.json());
    const data = req.json();
    return ({
      user_id: data.user.id,
      email: data.user.email,
    });
  } catch (e) {
    console.error(e);
    return (null);
  }
};
