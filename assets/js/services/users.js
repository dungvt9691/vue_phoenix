import Vue from 'vue';

function storedToken(token) {
  Vue.cookie.set('token', token, { expires: '1D' });
}

function accessToken() {
  return Vue.cookie.get('token');
}

function isSignedIn() {
  const token = Vue.cookie.get('token');
  if (token) {
    return true;
  }
  return false;
}

function userData() {
  return JSON.parse(localStorage.getItem('user'));
}

function updateUserData(data) {
  localStorage.setItem('user', JSON.stringify(data));
}

function signOut() {
  Vue.cookie.delete('token');
  localStorage.removeItem('user');
}

export default {
  storedToken,
  accessToken,
  isSignedIn,
  userData,
  updateUserData,
  signOut,
};
