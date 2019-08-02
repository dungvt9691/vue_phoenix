<template>
  <div class="auth-page">
    <img class="brand mb-2" src="/images/phoenix.png" alt="">
    <el-card class="box-card">
      <h1 class="title mb-2">Sign Up</h1>
      <sign-up-form></sign-up-form>
    </el-card>
  </div>
</template>

<script>
import SignUpForm from '../../components/auth/SignUpForm.vue';

export default {
  name: 'RegistrationsNew',
  components: {
    SignUpForm,
  },
};
</script>
