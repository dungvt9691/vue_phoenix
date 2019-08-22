<template>
  <div class="image-popup">
    <el-button
      class="close"
      type="text"
      size="large"
      @click="closePreview()"
    >
      <i class="el-icon-close"></i>
    </el-button>
    <div class="image">
      <div class="image__preview">
        <i v-if="callingAPI" class="loading el-icon-loading"></i>
        <img v-else
          :class="imgClass"
          :src="image.attributes.attachment.original"
          @load="(event) => setImgClass(event)"
          :alt="image.id">
        <div v-if="!callingAPI && siblings !== null" class="image__preview--direction">
          <a
            id="prev"
            class="prev"
            @click="previewImage(siblings.next)"
          >
            <i class="el-icon-arrow-left"></i>
          </a>
          <a
            id="next"
            class="next"
            @click="previewImage(siblings.prev)"
          >
            <i class="el-icon-arrow-right"></i>
          </a>
        </div>
      </div>
      <div class="image__content">
        <post-content
          @deleteImage="deleteImage"
          @updatePost="updatePost"
          :callingAPI="callingAPI"
          :user="user"
          :post="post"
        />
      </div>
    </div>
    <div @click="closePreview()" class="backdrop"></div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import axios from 'axios';
import userServices from '../../services/users';
import ENDPOINT from '../../config/endpoint';
import { extractObject } from '../../lib/common';
import PostContent from '../posts/Content.vue';

export default {
  name: 'ImagePreview',
  components: {
    PostContent,
  },
  computed: {
    ...mapGetters(['previewData']),
  },
  data() {
    return {
      imgClass: '',
      callingAPI: true,
      image: null,
      siblings: null,
      user: null,
      post: null,
    };
  },
  beforeMount() {
    if (this.previewData.imageId === '') {
      this.updatePreviewData({
        imageId: this.$route.params.id,
        postId: this.$route.params.postId,
        type: this.$route.params.show,
        currentPath: `/posts/${this.$route.params.postId}`,
      });
    }
    this.getImage();
    window.addEventListener('keyup', this.handleKeyup);
  },
  beforeDestroy() {
    window.removeEventListener('keyup', this.handleKeyup);
  },
  methods: {
    ...mapActions(['updateImagePreview', 'updatePreviewData']),

    updatePost(post) {
      this.post = post;
    },

    closePreview() {
      if (this.$route.name === 'ImageScreen') {
        this.$router.push({ path: this.previewData.currentPath });
      } else {
        window.history.pushState({}, null, this.previewData.currentPath);
      }
      this.updateImagePreview(false);
    },

    previewImage(sibling) {
      window.history.pushState({}, null, `/images/${sibling.post_id}/p/${sibling.id}`);
      this.updatePreviewData({
        imageId: sibling.id,
        postId: sibling.post_id,
        type: this.previewData.type,
        currentPath: this.previewData.currentPath,
      });
      this.getImage();
    },

    handleKeyup(event) {
      if (!this.editing && event.keyCode === 27) {
        this.closePreview();
      } else if (event.keyCode === 39) {
        document.getElementById('next').click();
      } else if (event.keyCode === 37) {
        document.getElementById('prev').click();
      }
    },

    setImgClass(event) {
      const image = event.target;
      const width = image.clientWidth;
      const height = image.clientHeight;
      if (width > height) {
        this.imgClass = 'horizontal';
      } else {
        this.imgClass = 'vertical';
      }
    },

    getImage() {
      this.callingAPI = true;
      const url = this.previewData.type === 'p'
        ? `${ENDPOINT.USER_IMAGES}/${this.previewData.imageId}?post_id=${this.previewData.postId}&include=post,user`
        : `${ENDPOINT.USER_IMAGES}/${this.previewData.imageId}?include=post,user`;
      axios.get(url, {
        headers: {
          Authorization: `Bearer ${userServices.accessToken()}`,
        },
      })
        .then((res) => {
          this.image = res.data.data;
          this.post = extractObject(res.data.included, res.data.data.relationships.post.data.id, 'post');
          this.user = extractObject(res.data.included, res.data.data.relationships.user.data.id, 'user');
          this.siblings = res.data.meta.siblings;
          this.callingAPI = false;
        })
        .catch((err) => {
          this.callingAPI = false;
          const { response } = err;
          let message = '';
          switch (response.status) {
            case 404:
              message = 'File not found';
              this.$router.push({ name: 'HomeScreen' });
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

    deleteImage() {
      this.$confirm('This will permanently delete the image. Continue?', 'Warning', {
        confirmButtonText: 'OK',
        cancelButtonText: 'Cancel',
        type: 'warning',
      }).then(() => {
        axios.delete(`${ENDPOINT.USER_IMAGES}/${this.previewData.imageId}`, {
          headers: {
            Authorization: `Bearer ${userServices.accessToken()}`,
          },
        })
          .then(() => {
            window.location.href = `/images/${this.siblings.next.post_id}/p/${this.siblings.next.id}`;
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
      }).catch(() => {
      });
    },
  },
};
</script>
