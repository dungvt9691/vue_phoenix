<template>
  <div class="auth-page">
    <img class="brand mb-2" src="/images/phoenix.png" alt="">
    <el-card class="box-card">
      <h1 class="title mb-2">Change Password</h1>
      <change-password-form></change-password-form>
    </el-card>
  </div>
</template>

<script>
import ChangePasswordForm from '../../components/auth/ChangePasswordForm.vue';

export default {
  name: 'sNew',
  components: {
    ChangePasswordForm,
  },
};
</script>
