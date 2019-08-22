import moment from 'moment';
// Common Javascript Functions
// eslint-disable-next-line import/prefer-default-export
export function parseError(errors) {
  const data = {};
  Object.keys(errors).forEach((key) => {
    data[key] = `${key.split('_').join(' ')} ${errors[key].join('<br>')}`;
  });
  return data;
}

export function convertDate(dateString, format) {
  if (dateString === null) return '';
  const stillUtc = moment.utc(dateString).toDate();
  return moment(stillUtc).local().format(format);
}

export function convertDateFromNow(dateString) {
  if (dateString === null) return '';
  const stillUtc = moment.utc(dateString).toDate();
  const localDateTime = moment(stillUtc).local();
  if (moment().diff(localDateTime, 'days') > 2) {
    return convertDate(localDateTime, 'MMMM Do YYYY');
  }
  return localDateTime.fromNow();
}

export function extractObject(includedObjects, id, type) {
  return includedObjects.find(obj => obj.type === type && obj.id === id);
}

export function extractArray(includedObjects, ids, type) {
  return ids.map(id => includedObjects.find(obj => obj.type === type && obj.id === id));
}

export function truncateContent(content, maxWords) {
  const strippedString = content.trim();
  const array = strippedString.split(' ');
  const wordCount = array.length;
  let string = array.splice(0, maxWords).join(' ');

  if (wordCount > maxWords) {
    string += '...';
  }

  return string;
}
