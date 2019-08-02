<template>
  <el-form
    label-position="top"
    :model="signUpForm"
    :rules="rules"
    ref="signUpForm"
    label-width="200px"
  >
    <el-form-item label="Email" prop="email">
      <el-input v-model="signUpForm.email"></el-input>
    </el-form-item>
    <el-form-item label="Password" prop="password">
      <el-input
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
    <el-form-item label="Password Confirmation" prop="passwordConfirmation">
      <el-input
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
      >
        Sign up
      </el-button>
      <span class="px-1">or</span>
      <el-button
        class="btn-facebook mt-1"
        type="primary"
        @click="submitForm('signUpForm')"
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
    };
  },
  methods: {
    submitForm(formName) {
      this.$refs[formName].validate((valid) => {
        if (valid) {
          console.log('submit!');
          return false;
        }
        console.log('error submit!!');
        return false;
      });
    },
  },
};
</script>
