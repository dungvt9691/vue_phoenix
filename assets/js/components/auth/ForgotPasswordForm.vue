<template>
  <el-form
    label-position="top"
    :model="forgotPasswordForm"
    :rules="rules"
    ref="forgotPasswordForm"
    label-width="120px"
  >
    <el-form-item :error="errors.email" label="Email" prop="email">
      <el-input :disabled="callingAPI" v-model="forgotPasswordForm.email"></el-input>
    </el-form-item>
    <el-form-item>
      <el-button
        :loading="callingAPI"
        class="mt-1"
        type="primary"
        @click="submitForm('forgotPasswordForm')"
      >
        Send verification email
      </el-button>
    </el-form-item>
    <el-row class="mt-4" :gutter="20">
      <el-col :span="10">
        Already Registered?
        <router-link :to="{ name: 'SignInScreen' }">
          Sign in
        </router-link>
      </el-col>
      <el-col :span="14" class="text-right">
        Don't have account?
        <router-link :to="{ name: 'SignUpScreen' }">
          Sign up now
        </router-link>
      </el-col>
    </el-row>
  </el-form>
</template>

<script>
import axios from 'axios';
import ENDPOINT from '../../config/endpoint';

export default {
  name: 'ForgotPasswordForm',
  data() {
    return {
      callingAPI: false,
      forgotPasswordForm: {
        email: '',
      },
      rules: {
        email: [
          { required: true, message: 'Please input email address', trigger: 'blur' },
          { type: 'email', message: 'Please input correct email address', trigger: ['blur', 'change'] },
        ],
      },
      errors: {
        email: '',
      },
    };
  },
  methods: {
    submitForm(formName) {
      this.$refs[formName].validate((valid) => {
        if (valid) {
          this.errors = {};
          this.callingAPI = true;
          axios.post(ENDPOINT.RESET_PASSWORD, {
            email: this.forgotPasswordForm.email,
          })
            .then(() => {
              this.$notify.success({
                title: 'Forgot password successfully',
                message: 'You will receive an email with instructions for how to reset your password in a few minutes.',
              });
              this.$router.push({ name: 'SignInScreen' });
            })
            .catch((err) => {
              this.callingAPI = false;
              const { response } = err;
              switch (response.status) {
                case 404:
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
        }
      });
    },
  },
};
</script>
