<template>
  <el-form
    class="post-new mb-2"
    :model="createPostForm"
    ref="createPostForm"
  >
    <el-form-item prop="content">
      <el-avatar
        v-if="profile.avatar.s50x50 === null"
        :size="40"
        src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png"
      ></el-avatar>
      <el-avatar
        v-else
        :size="40"
        :src="profile.avatar.s50x50"
      ></el-avatar>
      <el-input
        class="ml-1"
        placeholder="What's on your mind?"
        ref="content"
        type="textarea"
        :autosize="{ minRows: 1, maxRows: 20}"
        size="small"
        :disabled="callingAPI"
        v-model="createPostForm.content"
      ></el-input>
      <el-button
        @click="$refs.file.click()"
        type="text"
        size="mini"
        :disabled="callingAPI"
      >
        <i class="el-icon-paperclip"></i>
        <span>Photo</span>
      </el-button>
    </el-form-item>
    <el-form-item class="mb-0 files">
      <input
        accept=".jpg,.jpeg,.gif,.png,.JPG,.JPEG,.GIF,.PNG"
        class="d-none"
        type="file"
        ref="file"
        multiple
        @change="handleAttachFileInputChange($event.target.files)"
      >
      <el-row :gutter="4">
        <el-col v-for="(image, index) in postImages" :key="index" :span="6">
          <div class="file">
            <el-image
              v-if="image.uploadState === 'uploaded'"
              :src="image.attachment.s200x200"
            >
            </el-image>
            <div
              v-if="['uploading', 'pending'].includes(image.uploadState)"
              class="file__uploading"
            >
              <el-image src="/images/bg/gray.png"></el-image>
              <el-progress
                v-if="image.uploadState === 'uploading'"
                color="#FFFFFF"
                :stroke-width="3"
                :show-text="false"
                :width='50'
                type="circle"
                :percentage="image.uploadPercentage"
              ></el-progress>
            </div>
            <div v-if="image.uploadState === 'uploaded'" class="mask">
              <el-button
                type="text"
                @click="deleteImage(image.id)"
              >
                <i class="el-icon-close"></i>
              </el-button>
            </div>
          </div>
        </el-col>
      </el-row>
    </el-form-item>
    <el-form-item>
      <el-button
        class="mt-1"
        type="primary"
        size="mini"
        @click="submitForm"
        :disabled="createPostForm.content.replace(/\n/g, '') === ''"
        :loading="callingAPI || checkUploading()"
      >
        Post
      </el-button>
    </el-form-item>
  </el-form>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import axios from 'axios';
import { extractObject, extractArray } from '../../lib/common';
import userServices from '../../services/users';
import ENDPOINT from '../../config/endpoint';

export default {
  name: 'CreatePostForm',
  computed: {
    ...mapGetters(['profile', 'uploadedImages', 'totalImages']),
  },
  data() {
    return {
      callingAPI: false,
      postImages: [],
      createPostForm: {
        content: '',
      },
    };
  },
  beforeMount() {
    window.addEventListener('beforeunload', this.handleUnloadPage);
  },
  beforeDestroy() {
    window.removeEventListener('beforeunload', this.handleUnloadPage);
  },
  methods: {
    handleUnloadPage(event) {
      if (this.postImages.length > 0 || this.createPostForm.content !== '') {
        event.preventDefault();
        event.returnValue = null;
        this.postImages.forEach((image) => {
          this.callAPIDeleteImage(image.id);
        });
      }
    },

    ...mapActions(['updateUploadedImages', 'updateTotalImages']),

    checkUploading() {
      return this.postImages.filter(image => ['uploading', 'pending'].includes(image.uploadState)).length > 0;
    },

    handleAttachFileInputChange(fileList) {
      if (!fileList.length) return;

      this.postImages = Object.values(fileList).map(file => ({
        attachment: {
          s200x200: null,
        },
        file,
        uploadPercentage: 0,
        uploadState: 'pending',
        id: '',
      }));

      this.postImages.forEach((image) => {
        const formData = new FormData();
        formData.append('attachment', image.file);

        axios.post(ENDPOINT.USER_IMAGES, formData, {
          headers: {
            Authorization: `Bearer ${userServices.accessToken()}`,
            'Content-Type': 'multipart/form-data',
          },
          onUploadProgress: (e) => {
            image.uploadState = 'uploading';
            image.uploadPercentage = parseInt(Math.round((e.loaded * 100) / e.total), 0);
          },
        }).then((res) => {
          image.uploadState = 'uploaded';
          image.uploadPercentage = 0;
          image.attachment = res.data.data.attributes.attachment;
          image.id = res.data.data.id;
        }).catch((err) => {
          image.uploadState = 'failed';
          image.uploadPercentage = 0;
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
            title: `Upload ${image.name} Error`,
            message,
          });
        });
      });
    },

    submitForm() {
      this.$refs.createPostForm.validate((valid) => {
        if (valid) {
          this.callingAPI = true;

          axios.post(ENDPOINT.POSTS, {
            content: this.createPostForm.content,
            image_ids: this.postImages.map(image => image.id),
          }, {
            headers: {
              Authorization: `Bearer ${userServices.accessToken()}`,
            },
          })
            .then((res) => {
              const post = res.data.data;
              const imageIds = post.relationships.images.data.map(image => image.id);
              post.user = extractObject(res.data.included, post.relationships.user.data.id, 'user');
              post.images = extractArray(res.data.included, imageIds, 'image');
              if (this.$route.name === 'ProfileScreen') {
                this.updateUploadedImages(this.uploadedImages.concat(post.images));
                this.updateTotalImages(this.totalImages + post.images.length);
              }
              this.$emit('addPost', post);
              this.callingAPI = false;
              this.createPostForm.content = '';
              this.postImages = [];
            })
            .catch((err) => {
              this.callingAPI = false;
              this.$notify.error({
                title: 'Error',
                message: err,
              });
            });
        }
        return false;
      });

      return true;
    },

    deleteImage(id) {
      this.$confirm('This will permanently delete the image. Continue?', 'Warning', {
        confirmButtonText: 'OK',
        cancelButtonText: 'Cancel',
        type: 'warning',
      }).then(() => {
        this.callAPIDeleteImage(id);
      }).catch(() => {
      });
    },

    callAPIDeleteImage(id) {
      axios.delete(`${ENDPOINT.USER_IMAGES}/${id}`, {
        headers: {
          Authorization: `Bearer ${userServices.accessToken()}`,
        },
      })
        .then(() => {
          this.postImages = this.postImages.filter(image => image.id !== id);
        })
        .catch((err) => {
          const { response } = err;
          let message = '';
          switch (response.status) {
            case 404:
              message = 'File not found';
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
