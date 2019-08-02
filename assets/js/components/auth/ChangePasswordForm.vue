<template>
  <el-form
    label-position="top"
    :model="changePasswordForm"
    :rules="rules"
    ref="changePasswordForm"
    label-width="200px"
  >
    <el-form-item label="New Password" prop="password">
      <el-input
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
    <el-form-item label="New Password Confirmation" prop="passwordConfirmation">
      <el-input
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
    <el-form-item>
      <el-button
        class="mt-1"
        type="primary"
        @click="submitForm('changePasswordForm')"
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
      resetPasswordToken: '',
      isShowPassword: false,
      isShowPasswordConfirmation: false,
      changePasswordForm: {
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
    };
  },
  beforeMount() {
    this.resetPasswordToken = this.$route.query.reset_password_token;
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
