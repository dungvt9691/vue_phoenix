<template>
  <div id="app">
    <page-loading v-if="!authenticated && $route.meta.auth"/>
    <div v-else>
      <page-header v-if="isShowHeader"/>
      <router-view></router-view>
      <image-preview v-if="imagePreview"/>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import axios from 'axios';
import userServices from './services/users';
import ENDPOINT from './config/endpoint';
import PageHeader from './components/layout/Header.vue';
import PageLoading from './components/layout/PageLoading.vue';
import ImagePreview from './components/images/ImagePreview.vue';

export default {
  name: 'App',
  components: {
    PageHeader,
    PageLoading,
    ImagePreview,
  },
  computed: {
    ...mapGetters(['authenticated', 'imagePreview']),
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
    $route: ['checkShowHeader', 'getUserProfile'],
    imagePreview: (val) => {
      if (val) {
        document.body.style.overflow = 'hidden';
      } else {
        document.body.style.overflow = 'auto';
      }
    },
  },
  beforeMount() {
    this.checkShowHeader();
    this.getUserProfile();
  },
  methods: {
    ...mapActions(['updateAuthStatus', 'updateProfileData']),

    checkShowHeader() {
      if (this.notShowHeaderPages.includes(this.$route.name)) {
        this.isShowHeader = false;
      } else {
        this.isShowHeader = true;
      }
    },

    getUserProfile() {
      if (this.$route.meta.auth && !this.authenticated) {
        axios.get(ENDPOINT.USER_PROFILE, {
          headers: {
            Authorization: `Bearer ${userServices.accessToken()}`,
          },
        })
          .then((res) => {
            this.updateAuthStatus(true);
            this.updateProfileData(res.data.data.attributes);
          })
          .catch(() => {
            this.updateAuthStatus(true);
            userServices.signOut();
            this.$router.push({ name: 'SignInScreen' });
          });
      }
    },
  },
};
</script>
