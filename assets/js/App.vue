<template>
  <div id="app">
    <page-header v-if="isShowHeader"/>
    <router-view></router-view>
  </div>
</template>

<script>
import PageHeader from './components/layout/Header.vue';

export default {
  name: 'App',
  components: {
    PageHeader,
  },
  data() {
    return {
      notShowHeaderPages: [
        'SignInScreen',
        'SignUpScreen',
        'ForgotPasswordScreen',
        'ChangePasswordScreen',
      ],
      isShowHeader: true,
    };
  },
  watch: {
    $route: 'checkShowHeader',
  },
  beforeMount() {
    this.checkShowHeader();
  },
  methods: {
    checkShowHeader() {
      if (this.notShowHeaderPages.includes(this.$route.name)) {
        this.isShowHeader = false;
      } else {
        this.isShowHeader = true;
      }
    },
  },
};
</script>
