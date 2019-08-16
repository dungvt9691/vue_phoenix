<template>
  <fb-signin-button
    class="el-button el-button--primary btn-facebook"
    :params="fbSignInParams"
    @success="onSignInFBSuccess"
    @error="onSignInFBError">
    <i class="fab fa-facebook-f mr-1"></i>
    <slot></slot>
  </fb-signin-button>
</template>

<script>
import axios from 'axios';
import userServices from '../../services/users';
import ENDPOINT from '../../config/endpoint';

export default {
  name: 'FacebookSignIn',
  data() {
    return {
      fbSignInParams: {
        scope: 'email',
        return_scopes: true,
      },
    };
  },
  methods: {
    onSignInFBSuccess(fbResponse) {
      this.$emit('updateCallingAPI', true);
      axios.post(ENDPOINT.OAUTH, {
        access_token: fbResponse.authResponse.accessToken,
        provider: 'facebook',
      })
        .then((res) => {
          this.$emit('updateCallingAPI', false);
          userServices.storedToken(res.data.data.attributes.code);
          this.$router.push({ name: 'HomeScreen' });
        })
        .catch((err) => {
          this.$emit('updateCallingAPI', false);
          const { response } = err;
          switch (response.status) {
            case 401:
              this.errors = response.data.errors;
              break;
            default:
              this.$notify.error({
                title: 'Error',
                message: 'Something went wrong',
              });
              break;
          }
        });
    },

    onSignInFBError(error) {
      this.$notify.error({
        title: 'Error',
        message: error,
      });
    },
  },
};
</script>
