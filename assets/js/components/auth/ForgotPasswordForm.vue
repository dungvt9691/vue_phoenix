<template>
  <el-form
    label-position="top"
    :model="forgotPasswordForm"
    :rules="rules"
    ref="forgotPasswordForm"
    label-width="120px"
  >
    <el-form-item label="Email" prop="email">
      <el-input v-model="forgotPasswordForm.email"></el-input>
    </el-form-item>
    <el-form-item>
      <el-button
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
export default {
  name: 'ForgotPasswordForm',
  data() {
    return {
      forgotPasswordForm: {
        email: '',
      },
      rules: {
        email: [
          { required: true, message: 'Please input email address', trigger: 'blur' },
          { type: 'email', message: 'Please input correct email address', trigger: ['blur', 'change'] },
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
