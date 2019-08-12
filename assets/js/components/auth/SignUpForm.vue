<template>
  <el-form
    label-position="top"
    :model="signUpForm"
    :rules="rules"
    ref="signUpForm"
    label-width="200px"
  >
    <el-form-item :error="errors.email" label="Email" prop="email">
      <el-input :disabled="callingAPI" v-model="signUpForm.email"></el-input>
    </el-form-item>
    <el-form-item :error="errors.password" label="Password" prop="password">
      <el-input
        :disabled="callingAPI"
        :type="isShowPassword ? 'text' : 'password'"
        v-model="signUpForm.password"
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
        v-model="signUpForm.passwordConfirmation"
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
        @click="submitForm('signUpForm')"
        :loading="callingAPI"
      >
        Sign up
      </el-button>
      <span class="px-1">or</span>
      <el-button
        class="btn-facebook mt-1"
        type="primary"
        @click="submitForm('signUpForm')"
        :loading="callingAPI"
      >
        <i class="fab fa-facebook-f mr-1"></i>
        Sign up with Facebook
      </el-button>
    </el-form-item>
    <el-row class="mt-4" :gutter="20">
      <el-col :span="12">
        <router-link :to="{ name: 'ForgotPasswordScreen' }">
          Forgot password?
        </router-link>
      </el-col>
      <el-col :span="12" class="text-right">
        Already Registered?
        <router-link :to="{ name: 'SignInScreen' }">
          Sign in
        </router-link>
      </el-col>
    </el-row>
  </el-form>
</template>

<script>
import axios from 'axios';
import userServices from '../../services/users';
import { parseError } from '../../lib/common';

export default {
  name: 'SignUpForm',
  data() {
    const validatePass = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('Please input the password'));
      } else {
        if (this.signUpForm.passwordConfirmation !== '') {
          this.$refs.signUpForm.validateField('passwordConfirmation');
        }
        callback();
      }
    };
    const validatePass2 = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('Please input the password again'));
      } else if (value !== this.signUpForm.password) {
        callback(new Error('Password confirmation doesn\'t match!'));
      } else {
        callback();
      }
    };
    return {
      callingAPI: false,
      isShowPassword: false,
      isShowPasswordConfirmation: false,
      signUpForm: {
        email: '',
        password: '',
        passwordConfirmation: '',
      },
      rules: {
        email: [
          { required: true, message: 'Please input email address', trigger: 'blur' },
          { type: 'email', message: 'Please input correct email address', trigger: ['blur', 'change'] },
        ],
        password: [
          { validator: validatePass, trigger: 'blur' },
        ],
        passwordConfirmation: [
          { validator: validatePass2, trigger: 'blur' },
        ],
      },
      errors: {
        email: '',
        password: '',
        password_confirmation: '',
      },
    };
  },
  methods: {
    submitForm(formName) {
      this.errors = {};
      this.$refs[formName].validate((valid) => {
        if (valid) {
          this.callingAPI = true;
          axios.post('/api/register', {
            email: this.signUpForm.email,
            password: this.signUpForm.password,
            password_confirmation: this.signUpForm.passwordConfirmation,
          })
            .then((res) => {
              this.callingAPI = false;
              userServices.storedToken(res.data.data.attributes.code);
              this.$router.push({ name: 'HomeScreen' });
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
