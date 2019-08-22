// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import 'phoenix_html';

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import Vue from 'vue';
import ElementUI from 'element-ui';
import VueCookie from 'vue-cookie';
import FBSignInButton from 'vue-facebook-signin-button';
import PhotoGrid from 'vue-photo-grid';
import lang from 'element-ui/lib/locale/lang/en';
import locale from 'element-ui/lib/locale';

import '../css/app.scss';
import App from './App.vue';
import router from './router';
import store from './store/index';

// configure language
locale.use(lang);

Vue.use(ElementUI);
Vue.use(VueCookie);
Vue.use(FBSignInButton);
Vue.use(PhotoGrid);

new Vue({
  router,
  store,
  render: h => h(App),
}).$mount('#app');
