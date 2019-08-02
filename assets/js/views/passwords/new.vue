<template>
  <div class="auth-page">
    <img class="brand mb-2" src="/images/phoenix.png" alt="">
    <el-card class="box-card">
      <h1 class="title mb-2">Forgot Password</h1>
      <forgot-password-form></forgot-password-form>
    </el-card>
  </div>
</template>

<script>
import ForgotPasswordForm from '../../components/auth/ForgotPasswordForm.vue';

export default {
  name: 'sNew',
  components: {
    ForgotPasswordForm,
  },
};
</script>
