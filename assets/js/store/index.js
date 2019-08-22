import Vue from 'vue';
import Vuex from 'vuex';

import auth from './modules/auth';
import user from './modules/user';
import page from './modules/page';
import preview from './modules/preview';
import images from './modules/images';

Vue.use(Vuex);

export default new Vuex.Store({
  modules: {
    auth,
    user,
    images,
    page,
    preview,
  },
});
