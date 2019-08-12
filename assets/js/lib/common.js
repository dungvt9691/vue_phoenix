// Common Javascript Functions
// eslint-disable-next-line import/prefer-default-export
export function parseError(errors) {
  const data = {};
  Object.keys(errors).forEach((key) => {
    data[key] = `${key.split('_').join(' ')} ${errors[key].join('<br>')}`;
  });
  return data;
}
