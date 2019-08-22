<template>
  <div class="information">
    <div class="information--avatar">
      <el-avatar
        v-if="profile.avatar.s200x200 === null"
        shape="square"
        :size="150"
        src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png"
      ></el-avatar>
      <el-avatar
        v-else
        shape="square"
        fit="fill"
        :src="profile.avatar.s200x200"
      ></el-avatar>
      <el-progress
        v-if="uploading"
        color="#FFFFFF"
        :stroke-width="3"
        :show-text="false"
        :width='50'
        type="circle"
        :percentage="uploadPercentage"
      ></el-progress>
      <input
        accept=".jpg,.jpeg,.gif,.png,.JPG,.JPEG,.GIF,.PNG"
        ref="file"
        type="file"
        @change="handleAvatarChange($event.target.files)"
      >
      <div @click="$refs.file.click()" v-if="!uploading" class="mask">
        <i class="fas fa-camera"></i>
        <span class="ml-1">Update</span>
      </div>
    </div>
    <div class="information--identify">
      <h1 v-if="profile.full_name && !showIdentifyForm">
        {{ profile.full_name || profile.email }}
        <el-button
            type="text"
            size="small"
            @click="showIdentifyForm = true"
          >
          <i class="edit el-icon-edit"></i>
        </el-button>
      </h1>
      <div v-else>
        <identify-form :profile="profile" @hideIdentifyForm="showIdentifyForm = false"/>
      </div>
    </div>
    <div class="information--rows">
      <div class="information--rows__row">
        <div class="birthday mt-1" v-if="profile.birthday && !showBirthdayForm">
          <i class="fas fa-birthday-cake mr-1"></i>
          <span >
            {{ convertDate(profile.birthday, 'dddd, MMMM Do YYYY') }}
          </span>
          <el-button
            type="text"
            size="small"
            @click="showBirthdayForm = true"
          >
            <i class="edit el-icon-edit"></i>
          </el-button>
        </div>
        <div class="birthday mt-1" v-else>
          <birthday-form :profile="profile" @hideBirthdayForm="showBirthdayForm = false"/>
        </div>
      </div>
      <div class="information--rows__row">
        <div class="password">
          <i class="fas fa-lock mr-1"></i>
          <el-button
            type="text"
            size="small"
            @click="showChangePasswordForm = true"
          >
            Change Password
          </el-button>
        </div>
        <el-dialog
          :close-on-click-modal="false"
          :close-on-press-escape="false"
          :show-close='false'
          title="Change Password"
          :visible.sync="showChangePasswordForm"
          width="350px">
          <span>
            <change-password-form ref="changePasswordForm"/>
          </span>
          <span slot="footer" class="dialog-footer">
            <el-button @click="showChangePasswordForm = false">Cancel</el-button>
            <el-button type="primary" @click="handleChangePassword">Change Password</el-button>
          </span>
        </el-dialog>
      </div>
    </div>
    <div class="information--images mt-3">
      <uploaded-images/>
    </div>
  </div>
</template>

<script>
import { mapActions } from 'vuex';
import axios from 'axios';
import { convertDate } from '../../lib/common';
import userServices from '../../services/users';
import ENDPOINT from '../../config/endpoint';
import IdentifyForm from './IdentifyForm.vue';
import BirthdayForm from './BirthdayForm.vue';
import ChangePasswordForm from './ChangePasswordForm.vue';
import UploadedImages from './UploadedImages.vue';

export default {
  name: 'ProfileInformation',
  components: {
    IdentifyForm,
    BirthdayForm,
    ChangePasswordForm,
    UploadedImages,
  },
  props: ['profile'],
  data() {
    return {
      uploading: false,
      uploadPercentage: 0,
      showIdentifyForm: false,
      showBirthdayForm: false,
      showChangePasswordForm: false,
    };
  },
  methods: {
    convertDate,

    ...mapActions(['updateProfileData']),

    handleChangePassword() {
      this.$refs.changePasswordForm.submitForm();
    },

    handleAvatarChange(files) {
      this.uploading = true;
      const formData = new FormData();
      formData.append('avatar', files[0]);
      axios.put(ENDPOINT.USER_PROFILE, formData, {
        headers: {
          Authorization: `Bearer ${userServices.accessToken()}`,
          'Content-Type': 'multipart/form-data',
        },
        onUploadProgress: (e) => {
          this.uploadPercentage = parseInt(Math.round((e.loaded * 100) / e.total), 0);
        },
      }).then((res) => {
        this.uploading = false;
        this.uploadPercentage = 0;
        this.updateProfileData(res.data.data.attributes);
      }).catch((err) => {
        this.uploading = false;
        const { response } = err;
        let message = '';
        switch (response.status) {
          case 422:
            message = 'Invalid file';
            break;
          case 413:
            message = 'File size exceeds the allowable limit of 25MB';
            break;
          default:
            message = 'Something went wrong';
            break;
        }

        this.$notify.error({
          title: 'Error',
          message,
        });
      });
    },
  },
};
</script>
