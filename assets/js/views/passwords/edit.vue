<template>
  <div class="auth-page">
    <img class="brand mb-2" src="/images/phoenix.png" alt="">
    <el-card class="box-card">
      <h1 class="title mb-2">Change Password</h1>
      <reset-password-form></reset-password-form>
    </el-card>
  </div>
</template>

<script>
import ResetPasswordForm from '../../components/auth/ResetPasswordForm.vue';

export default {
  name: 'sNew',
  components: {
    ResetPasswordForm,
  },
};
</script>
