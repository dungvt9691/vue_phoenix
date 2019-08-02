<template>
  <div class="auth-page">
    <img class="brand mb-2" src="/images/phoenix.png" alt="">
    <el-card class="box-card">
      <h1 class="title mb-2">Sign In</h1>
      <sign-in-form></sign-in-form>
    </el-card>
  </div>
</template>

<script>
import SignInForm from '../../components/auth/SignInForm.vue';

export default {
  name: 'SessionsNew',
  components: {
    SignInForm,
  },
};
</script>
