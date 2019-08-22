<template>
  <div class="posts">
    <create-post-form @addPost="addPost"/>
    <post-content
      class="mb-2"
      @updatePost="updatePost"
      @deletePost="deletePost"
      :callingAPI="false"
      :user="post.user"
      :post="post"
      v-for="post in uploadedPosts"
      :key="post.id"
    />
    <div v-if="callingAPI" class="mb-2 post-content">
      <div class="post-loading">
        <post-loading/>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import axios from 'axios';
import { extractObject, extractArray } from '../../lib/common';
import userServices from '../../services/users';
import ENDPOINT from '../../config/endpoint';
import CreatePostForm from '../posts/CreateForm.vue';
import PostContent from '../posts/Content.vue';
import PostLoading from '../posts/Loading.vue';

export default {
  name: 'UploadedPosts',
  components: {
    PostContent,
    PostLoading,
    CreatePostForm,
  },
  computed: {
    ...mapGetters(['profile']),
  },
  data() {
    return {
      callingAPI: true,
      uploadedPosts: [],
      currentPage: 1,
      limit: 5,
      totalPages: 1,
    };
  },
  beforeMount() {
    this.getUploadedPosts(this.currentPage);
  },
  mounted() {
    this.scroll();
  },
  methods: {
    ...mapActions(['updateCurrentScreen']),

    scroll() {
      window.onscroll = () => {
        const bottomOfWindow = Math.max(
          window.pageYOffset,
          document.documentElement.scrollTop,
          document.body.scrollTop,
        ) + window.innerHeight === document.documentElement.offsetHeight;

        if (this.currentPage < this.totalPages && bottomOfWindow) {
          this.getUploadedPosts(this.currentPage + 1);
        }
      };
    },

    addPost(post) {
      this.uploadedPosts.unshift(post);
    },

    updatePost(post) {
      const editedPost = this.uploadedPosts.find(p => post.id === p.id);
      this.uploadedPosts.splice(this.uploadedPosts.indexOf(editedPost), 1, post);
    },

    deletePost(id) {
      this.uploadedPosts = this.uploadedPosts.filter(post => post.id !== id);
    },

    getUploadedPosts(page) {
      this.callingAPI = true;
      axios.get(`${ENDPOINT.USER_POSTS}?page=${page}&limit=${this.limit}&include=user,images`, {
        headers: {
          Authorization: `Bearer ${userServices.accessToken()}`,
        },
      })
        .then((res) => {
          res.data.data.forEach((post) => {
            const data = post;
            const imageIds = post.relationships.images.data.map(image => image.id);
            data.user = extractObject(res.data.included, post.relationships.user.data.id, 'user');
            data.images = extractArray(res.data.included, imageIds, 'image');
            this.uploadedPosts.push(data);
          });
          this.totalPages = parseInt(res.headers['total-pages'], 0);
          this.totalPosts = parseInt(res.headers.total, 0);
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
