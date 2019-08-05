// Common Javascript Functions
// eslint-disable-next-line import/prefer-default-export
export function parseError(key, errors) {
  try {
    return errors.map(error => `${key} ${error}`).join('<br>');
  } catch (_error) {
    return '';
  }
}
