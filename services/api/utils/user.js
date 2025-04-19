export const getRandomNumber = (min, max) => {
  return parseInt(Math.random() * (max - min) + min, 10);
};

export const generateConfirmationCode = () => {
  let code = [];
  while (code.length < 4) {
    code.push(getRandomNumber(0, 9));
  }
  return (parseInt(code.join(""), 10));
};
