<template>
  <el-form
    :model="identifyForm"
    :rules="rules"
    :inline="true"
    ref="identifyForm"
    label-width="50px"
  >
    <el-form-item size="small" :show-message="false" prop="firstName">
      <el-input
        placeholder="First name"
        :disabled="callingAPI"
        v-model="identifyForm.firstName"
      ></el-input>
    </el-form-item>
    <el-form-item size="small" :show-message="false" prop="lastName">
      <el-input
        placeholder="Last name"
        :disabled="callingAPI"
        v-model="identifyForm.lastName"
      ></el-input>
    </el-form-item>
    <el-form-item size="small" :show-message="false">
      <el-button
        type="text"
        size="mini"
        @click="submitForm('identifyForm')"
      >
        <i class="fas fa-check"></i>
      </el-button>
      <el-button
        type="text"
        size="mini"
        @click="hideIdentifyForm"
      >
        <i class="fas fa-times"></i>
      </el-button>
    </el-form-item>
  </el-form>
</template>

<script>
import { mapActions } from 'vuex';
import axios from 'axios';
import userServices from '../../services/users';
import ENDPOINT from '../../config/endpoint';

export default {
  name: 'IdentifyForm',
  props: ['profile'],
  data() {
    return {
      callingAPI: false,
      identifyForm: {
        firstName: this.profile.first_name,
        lastName: this.profile.last_name,
      },
      rules: {
        firstName: [
          { required: true },
        ],
        lastName: [
          { required: true },
        ],
      },
    };
  },
  methods: {
    ...mapActions(['updateProfileData']),

    hideIdentifyForm() {
      this.$emit('hideIdentifyForm');
    },

    submitForm(formName) {
      this.$refs[formName].validate((valid) => {
        if (valid) {
          this.callingAPI = true;
          axios.put(ENDPOINT.USER_PROFILE, {
            first_name: this.identifyForm.firstName,
            last_name: this.identifyForm.lastName,
          }, {
            headers: {
              Authorization: `Bearer ${userServices.accessToken()}`,
            },
          })
            .then((res) => {
              this.callingAPI = false;
              this.updateProfileData(res.data.data.attributes);
              this.$emit('hideIdentifyForm');
            })
            .catch((err) => {
              this.callingAPI = false;
              this.$notify.error({
                title: 'Error',
                message: err,
              });
            });
        }
      });
    },
  },
};
</script>
