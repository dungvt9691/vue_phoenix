<template>
  <div class="post-content">
    <div v-if="callingAPI" class="post-loading">
      <post-loading/>
    </div>
    <div v-else class="post">
      <div class="post__user">
        <div class="post__user--avatar mr-1">
          <el-avatar
            v-if="user.attributes.avatar.s50x50 === null"
            :size="40"
            src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png"
          ></el-avatar>
          <el-avatar
            v-else
            :size="40"
            :src="user.attributes.avatar.s50x50"
          ></el-avatar>
        </div>
        <div class="post__user--info">
          <strong class="name">
            {{ user.attributes.full_name || user.attributes.email }}
          </strong>
          <span class="created">
            {{ convertDateFromNow(post.attributes.inserted_at) }}
          </span>
        </div>
        <div
          v-if="profile.email === user.attributes.email"
          class="post__actions"
        >
          <el-dropdown
            @command="callAction"
            class="ml-1"
            trigger="click"
          >
            <el-button
              type="text"
              size="mini"
              block
            >
              <i class="el-icon-more"></i>
            </el-button>
            <el-dropdown-menu slot="dropdown">
              <el-dropdown-item
                :icon="'el-icon-edit'"
                :command="'editPost'"
              >
                Edit post
              </el-dropdown-item>
              <el-dropdown-item
                v-if="imagePreview"
                :icon="'el-icon-delete'"
                :command="'deleteImage'"
              >
                Delete image
              </el-dropdown-item>
              <el-dropdown-item
                v-else
                :icon="'el-icon-delete'"
                :command="'deletePost'"
              >
                Delete post
              </el-dropdown-item>
            </el-dropdown-menu>
          </el-dropdown>
        </div>
      </div>
      <div v-if="showEditForm" class="post__editForm">
        <edit-post-form @updatePost="updatePost" :post="post" @closeEditForm="closeEditForm"/>
      </div>
      <div v-else>
        <div
          v-if="compact && post.attributes.content.split(' ').length >= maxWords"
          class="post__content"
        >
          <span v-html="compactContent.replace(/\n/g, '<br>')"></span>
          <span class="read-more" @click="compact = false">Read more</span>
        </div>
        <div v-else class="post__content">
          <span v-html="post.attributes.content.replace(/\n/g, '<br>')"></span>
        </div>
      </div>
      <div v-if="post.images && post.images.length > 0" id="photo-grid">
        <photo-grid
          :box-height="'500px'"
          :box-width="'100%'"
          :excess-text="'+{{count}}'"
          @clickExcess="previewImage(post.images[3])"
        >
          <img
            @click="previewImage(image)"
            v-for="image in post.images"
            :key="`1-${image.id}`"
            v-bind:src="image.attributes.attachment.s500x"
          />
        </photo-grid>
      </div>
      <div class="post_comments">
        <post-comments :post="post"/>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import axios from 'axios';
import { convertDateFromNow, truncateContent } from '../../lib/common';
import userServices from '../../services/users';
import ENDPOINT from '../../config/endpoint';
import PostLoading from './Loading.vue';
import PostComments from './Comments.vue';
import EditPostForm from './EditForm.vue';

export default {
  name: 'PostContent',
  props: ['user', 'post', 'callingAPI', 'siblings'],
  data() {
    return {
      compact: true,
      maxWords: 50,
      showEditForm: false,
    };
  },
  components: {
    PostComments,
    EditPostForm,
    PostLoading,
  },
  computed: {
    ...mapGetters([
      'profile',
      'imagePreview',
      'previewData',
      'uploadedImages',
      'totalImages',
    ]),

    compactContent() {
      if (this.post.attributes.content.split(' ').length >= this.maxWords) {
        return truncateContent(this.post.attributes.content, this.maxWords);
      }
      return this.post.attributes.content;
    },
  },
  watch: {
    $route: 'closeEditForm',
  },
  methods: {
    convertDateFromNow,

    ...mapActions([
      'updateEditing',
      'updateImagePreview',
      'updatePreviewData',
      'updateUploadedImages',
      'updateTotalImages',
    ]),

    previewImage(image) {
      this.updatePreviewData({
        imageId: image.id,
        postId: this.post.id,
        type: 'p',
        currentPath: window.location.pathname,
      });
      window.history.pushState({}, null, `/images/${this.post.id}/p/${image.id}`);
      this.updateImagePreview(true);
    },

    updatePost(post) {
      this.$emit('updatePost', post);
    },

    closeEditForm() {
      this.showEditForm = false;
    },

    callAction(command) {
      if (command === 'editPost') {
        this.showEditForm = true;
        this.updateEditing(true);
      } else if (command === 'deleteImage') {
        this.$emit('deleteImage');
      } else {
        this.deletePost();
      }
    },

    deletePost() {
      this.$confirm('Are you sure you want to delete this post?', 'Warning', {
        confirmButtonText: 'OK',
        cancelButtonText: 'Cancel',
        type: 'warning',
      }).then(() => {
        axios.delete(`${ENDPOINT.POSTS}/${this.post.id}`, {
          headers: {
            Authorization: `Bearer ${userServices.accessToken()}`,
          },
        })
          .then(() => {
            const imageIds = this.post.images.map(image => image.id);
            this.updateUploadedImages(
              this.uploadedImages.filter(
                image => !imageIds.includes(image.id),
              ),
            );
            this.updateTotalImages(this.totalImages - imageIds.length);
            this.$emit('deletePost', this.post.id);
          })
          .catch((err) => {
            console.log(err);
            const { response } = err;
            let message = '';
            switch (response.status) {
              case 404:
                message = 'Post not found';
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
