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

function signOut() {
  Vue.cookie.delete('token');
}

export default {
  storedToken,
  accessToken,
  isSignedIn,
  signOut,
};
