import jwtDecode from 'jwt-decode';

function isSignedIn() {
  const user = JSON.parse(localStorage.getItem('user'));
  if (user && user.jwt) {
    const content = jwtDecode(user.jwt);
    const now = Math.floor(Date.now() / 1000);
    if (content.exp < now) {
      localStorage.removeItem('user');
      window.location.href = '/sign-in';
    }
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
  localStorage.removeItem('user');
}

export default {
  isSignedIn,
  userData,
  updateUserData,
  signOut,
};
