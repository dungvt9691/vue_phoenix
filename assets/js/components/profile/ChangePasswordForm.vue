<template>
  <el-form
    label-position="top"
    :model="changePasswordForm"
    :rules="rules"
    ref="changePasswordForm"
    label-width="200px"
  >
    <el-form-item :error="errors.password" label="Password" prop="password">
      <el-input
        :disabled="callingAPI"
        :type="isShowPassword ? 'text' : 'password'"
        v-model="changePasswordForm.password"
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
      label="Password Confirmation"
      prop="passwordConfirmation"
    >
      <el-input
        :disabled="callingAPI"
        :type="isShowPasswordConfirmation ? 'text' : 'password'"
        v-model="changePasswordForm.passwordConfirmation"
        autocomplete="off"
      >
        <i
          @click="isShowPasswordConfirmation = !isShowPasswordConfirmation"
          slot="suffix"
          :class="['fas mr-1', isShowPasswordConfirmation ? 'fa-eye-slash' : 'fa-eye']"
        ></i>
      </el-input>
    </el-form-item>
  </el-form>
</template>

<script>
import axios from 'axios';
import userServices from '../../services/users';
import { parseError } from '../../lib/common';
import ENDPOINT from '../../config/endpoint';

export default {
  name: 'ChangePasswordForm',
  data() {
    const validatePass = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('Please input the password'));
      } else {
        if (this.changePasswordForm.passwordConfirmation !== '') {
          this.$refs.changePasswordForm.validateField('passwordConfirmation');
        }
        callback();
      }
    };
    const validatePass2 = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('Please input the password again'));
      } else if (value !== this.changePasswordForm.password) {
        callback(new Error('Password confirmation doesn\'t match!'));
      } else {
        callback();
      }
    };
    return {
      callingAPI: false,
      isShowPassword: false,
      isShowPasswordConfirmation: false,
      changePasswordForm: {
        password: '',
        passwordConfirmation: '',
      },
      rules: {
        password: [
          { required: true, message: 'Please input the password', trigger: 'blur' },
          { validator: validatePass, trigger: 'blur' },
        ],
        passwordConfirmation: [
          { required: true, message: 'Please input the password again', trigger: 'blur' },
          { validator: validatePass2, trigger: 'blur' },
        ],
      },
      errors: {
        password: '',
        password_confirmation: '',
      },
    };
  },
  methods: {
    submitForm() {
      this.$refs.changePasswordForm.validate((valid) => {
        if (valid) {
          this.callingAPI = true;
          axios.put(ENDPOINT.USER_PROFILE, {
            password: this.changePasswordForm.password,
            password_confirmation: this.changePasswordForm.passwordConfirmation,
          }, {
            headers: {
              Authorization: `Bearer ${userServices.accessToken()}`,
            },
          })
            .then(() => {
              this.callingAPI = false;
              this.$notify.success({
                title: 'Changed password successfully',
                message: 'You can sign in to website with the new password from now',
              });
              this.$emit('hideChangePasswordForm');
              const token = userServices.accessToken();
              userServices.signOut();
              this.$router.push({ name: 'SignInScreen' });
              axios.delete(ENDPOINT.AUTH, {
                headers: {
                  Authorization: `Bearer ${token}`,
                },
              })
                .then(() => {
                  this.updateAuthStatus(false);
                })
                .catch((err) => {
                  this.updateAuthStatus(false);
                  this.$notify.error({
                    title: 'Error',
                    message: err,
                  });
                });
            })
            .catch((err) => {
              this.callingAPI = false;
              const { response } = err;
              switch (response.status) {
                case 422:
                  this.errors = parseError(response.data.errors);
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
