<template>
  <el-form
    label-position="top"
    :model="resetPasswordForm"
    :rules="rules"
    ref="resetPasswordForm"
    label-width="200px"
  >
    <el-form-item :error="errors.password" label="New Password" prop="password">
      <el-input
        :disabled="callingAPI"
        :type="isShowPassword ? 'text' : 'password'"
        v-model="resetPasswordForm.password"
        autocomplete="off"
      >
        <i
          @click="isShowPassword = !isShowPassword"
          slot="suffix"
          :class="['fas mr-1', isShowPassword ? 'fa-eye-slash' : 'fa-eye']"
        ></i>
      </el-input>
    </el-form-item>
    <el-form-item
      :error="errors.password_confirmation"
      label="New Password Confirmation"
      prop="passwordConfirmation"
    >
      <el-input
        :disabled="callingAPI"
        :type="isShowPasswordConfirmation ? 'text' : 'password'"
        v-model="resetPasswordForm.passwordConfirmation"
        autocomplete="off"
      >
        <i
          @click="isShowPasswordConfirmation = !isShowPasswordConfirmation"
          slot="suffix"
          :class="['fas mr-1', isShowPasswordConfirmation ? 'fa-eye-slash' : 'fa-eye']"
        ></i>
      </el-input>
    </el-form-item>
    <el-form-item>
      <el-button
        class="mt-1"
        type="primary"
        @click="submitForm('resetPasswordForm')"
        :loading="callingAPI"
      >
        Change password
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
import userServices from '../../services/users';
import { parseError } from '../../lib/common';
import ENDPOINT from '../../config/endpoint';

export default {
  name: 'ResetPasswordForm',
  data() {
    const validatePass = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('Please input the password'));
      } else {
        if (this.resetPasswordForm.passwordConfirmation !== '') {
          this.$refs.resetPasswordForm.validateField('passwordConfirmation');
        }
        callback();
      }
    };
    const validatePass2 = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('Please input the password again'));
      } else if (value !== this.resetPasswordForm.password) {
        callback(new Error('Password confirmation doesn\'t match!'));
      } else {
        callback();
      }
    };
    return {
      callingAPI: false,
      resetPasswordToken: '',
      isShowPassword: false,
      isShowPasswordConfirmation: false,
      resetPasswordForm: {
        password: '',
        passwordConfirmation: '',
      },
      rules: {
        password: [
          { validator: validatePass, trigger: 'blur' },
        ],
        passwordConfirmation: [
          { validator: validatePass2, trigger: 'blur' },
        ],
      },
      errors: {
        password: '',
        password_confirmation: '',
      },
    };
  },
  beforeMount() {
    this.resetPasswordToken = this.$route.query.token;
  },
  methods: {
    submitForm(formName) {
      this.$refs[formName].validate((valid) => {
        if (valid) {
          this.errors = {};
          this.callingAPI = true;
          axios.put(ENDPOINT.RESET_PASSWORD, {
            reset_password_token: this.resetPasswordToken,
            password: this.resetPasswordForm.password,
            password_confirmation: this.resetPasswordForm.passwordConfirmation,
          })
            .then(() => {
              this.callingAPI = false;
              this.$notify.success({
                title: 'Changed password successfully',
                message: 'You can sign in to website with the new password from now.',
              });
              this.$router.push({ name: 'SignInScreen' });
            })
            .catch((err) => {
              this.callingAPI = false;
              const { response } = err;
              switch (response.status) {
                case 422:
                  this.errors = parseError(response.data.errors);
                  break;
                case 404:
                  this.$notify.error({
                    title: 'Error',
                    message: 'Reset password token is invalid or expired',
                  });
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
