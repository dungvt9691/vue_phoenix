import Vue from 'vue';
import Router from 'vue-router';
import HomeScreen from './views/home/index.vue';
import SignInScreen from './views/sessions/new.vue';
import SignUpScreen from './views/registrations/new.vue';
import ForgotPasswordScreen from './views/passwords/new.vue';
import ResetPasswordScreen from './views/passwords/edit.vue';

import userServices from './services/users';

Vue.use(Router);

const router = new Router({
  mode: 'history',
  routes: [
    {
      path: '/',
      name: 'HomeScreen',
      component: HomeScreen,
      meta: { auth: true },
    },
    {
      path: '/sign-in',
      name: 'SignInScreen',
      component: SignInScreen,
      meta: { auth: false },
    },
    {
      path: '/sign-up',
      name: 'SignUpScreen',
      component: SignUpScreen,
      meta: { auth: false },
    },
    {
      path: '/forgot-password',
      name: 'ForgotPasswordScreen',
      component: ForgotPasswordScreen,
      meta: { auth: false },
    },
    {
      path: '/reset-password',
      name: 'ResetPasswordScreen',
      component: ResetPasswordScreen,
      meta: { auth: false },
    },
  ],
});

router.beforeEach((to, _from, next) => {
  const isSignedIn = userServices.isSignedIn();

  if (to.meta && to.meta.auth !== undefined) {
    if (to.meta.auth) {
      if (!isSignedIn) {
        router.push({ name: 'SignInScreen' });
      } else {
        next();
      }
    } else if (!isSignedIn) {
      next();
    } else {
      router.push({ name: 'HomeScreen' });
    }
  } else {
    next();
  }
});

export default router;
