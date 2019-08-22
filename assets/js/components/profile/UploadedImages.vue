<template>
  <div>
    <h4 class="mb-1">
      Uploaded images
      <strong class="text-muted">{{ `(${this.totalImages})` }}</strong>
    </h4>
    <el-row :gutter="4">
      <el-alert
        v-if="!callingAPI && uploadedImages.length === 0"
        title="There are no images that you uploaded"
        :closable="false"
        type="warning">
      </el-alert>
      <el-col v-for="image in uploadedImages" :key="image.id" :span="8">
        <div class="image">
          <el-image
            :src="image.attributes.attachment.s200x200"
          >
          </el-image>
          <div @click="previewImage(image)" class="mask">
          </div>
        </div>
      </el-col>
      <el-col v-if="totalPages > 1 && currentPage !== totalPages" :span="24">
        <el-button
          class="mt-1 btn-view-more"
          type="text"
          size="small"
          block
          :loading="callingAPI"
          @click="getUploadedImages(currentPage + 1)"
        >
          View more
        </el-button>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import axios from 'axios';
import userServices from '../../services/users';
import ENDPOINT from '../../config/endpoint';

export default {
  name: 'UploadedImages',
  computed: {
    ...mapGetters([
      'profile',
      'uploadedImages',
      'totalImages',
    ]),
  },
  data() {
    return {
      callingAPI: true,
      currentPage: 1,
      limit: 3,
      totalPages: 1,
    };
  },
  beforeMount() {
    this.getUploadedImages(this.currentPage);
  },
  methods: {
    ...mapActions([
      'updateImagePreview',
      'updatePreviewData',
      'updateUploadedImages',
      'updateTotalImages',
    ]),

    previewImage(image) {
      const postId = image.relationships.post.data.id;
      this.updatePreviewData({
        imageId: image.id,
        postId,
        type: 'a',
        currentPath: window.location.pathname,
      });
      window.history.pushState({}, null, `/images/${postId}/a/${image.id}`);
      this.updateImagePreview(true);
    },

    getUploadedImages(page) {
      this.callingAPI = true;
      axios.get(`${ENDPOINT.USER_IMAGES}?page=${page}&limit=${this.limit}&include=post`, {
        headers: {
          Authorization: `Bearer ${userServices.accessToken()}`,
        },
      })
        .then((res) => {
          this.updateUploadedImages(this.uploadedImages.concat(res.data.data));
          this.updateTotalImages(parseInt(res.headers.total, 0));
          this.totalPages = parseInt(res.headers['total-pages'], 0);
          this.currentPage = parseInt(res.headers['page-number'], 0);
          this.callingAPI = false;
        })
        .catch((err) => {
          this.callingAPI = false;
          this.$notify.error({
            title: 'Error',
            message: err,
          });
        });
    },
  },
};
</script>
