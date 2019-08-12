<template>
  <el-form
    label-position="top"
    :model="signInForm"
    :rules="rules"
    ref="signInForm"
    label-width="120px"
  >
    <el-form-item :error="errors.email" label="Email" prop="email">
      <el-input :disabled="callingAPI" v-model="signInForm.email"></el-input>
    </el-form-item>
    <el-form-item :error="errors.password" label="Password" prop="password">
      <el-input
        :disabled="callingAPI"
        :type="isShowPassword ? 'text' : 'password'"
        v-model="signInForm.password"
        autocomplete="off"
      >
        <i
          @click="isShowPassword = !isShowPassword"
          slot="suffix"
          :class="['fas mr-1', isShowPassword ? 'fa-eye-slash' : 'fa-eye']"
        ></i>
      </el-input>
    </el-form-item>
    <el-form-item>
      <el-button
        class="mt-1"
        type="primary"
        @click="submitForm('signInForm')"
        :loading="callingAPI"
      >
        Sign in
      </el-button>
      <span class="px-1">or</span>
      <el-button
        class="btn-facebook mt-1"
        type="primary"
        @click="submitForm('signInForm')"
        :loading="callingAPI"
      >
        <i class="fab fa-facebook-f mr-1"></i>
        Sign in with Facebook
      </el-button>
    </el-form-item>
    <el-row class="mt-4" :gutter="20">
      <el-col :span="10">
        <router-link :to="{ name: 'ForgotPasswordScreen' }">
          Forgot password?
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

export default {
  name: 'SignInForm',
  data() {
    return {
      callingAPI: false,
      isShowPassword: false,
      signInForm: {
        email: '',
        password: '',
      },
      rules: {
        email: [
          { required: true, message: 'Please input email address', trigger: 'blur' },
          { type: 'email', message: 'Please input correct email address', trigger: ['blur', 'change'] },
        ],
        password: [
          { required: true, message: 'Please input password', trigger: 'blur' },
        ],
      },
      errors: {
        email: '',
        password: '',
      },
    };
  },
  methods: {
    submitForm(formName) {
      this.errors = {};
      this.$refs[formName].validate((valid) => {
        if (valid) {
          this.callingAPI = true;
          axios.post('/api/auth', {
            email: this.signInForm.email,
            password: this.signInForm.password,
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
        }
      });
    },
  },
};
</script>
