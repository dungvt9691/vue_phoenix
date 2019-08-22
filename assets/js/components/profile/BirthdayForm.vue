<template>
  <el-form
    :model="birthdayForm"
    :rules="rules"
    :inline="true"
    ref="birthdayForm"
  >
    <el-form-item size="small" :show-message="false" prop="birthday">
      <el-date-picker
        :disabled="callingAPI"
        v-model="birthdayForm.birthday"
        type="date"
        placeholder="Birthday">
      </el-date-picker>
    </el-form-item>
    <el-form-item size="small" :show-message="false">
      <el-button
        type="text"
        size="small"
        @click="submitForm('birthdayForm')"
      >
        <i class="fas fa-check"></i>
      </el-button>
      <el-button
        type="text"
        size="small"
        @click="hideBirthdayForm"
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
import { convertDate } from '../../lib/common';

export default {
  name: 'BirthdayForm',
  props: ['profile'],
  data() {
    return {
      callingAPI: false,
      birthdayForm: {
        birthday: convertDate(this.profile.birthday, 'YYYY-MM-DD'),
      },
      rules: {
        birthday: [
          { required: true },
        ],
      },
    };
  },
  methods: {
    ...mapActions(['updateProfileData']),

    hideBirthdayForm() {
      this.$emit('hideBirthdayForm');
    },

    submitForm(formName) {
      this.$refs[formName].validate((valid) => {
        if (valid) {
          this.callingAPI = true;
          axios.put(ENDPOINT.USER_PROFILE, {
            birthday: this.birthdayForm.birthday,
          }, {
            headers: {
              Authorization: `Bearer ${userServices.accessToken()}`,
            },
          })
            .then((res) => {
              this.callingAPI = false;
              this.updateProfileData(res.data.data.attributes);
              this.$emit('hideBirthdayForm');
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
