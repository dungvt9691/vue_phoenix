<template>
  <div class="post-page">
    <el-container>
      <el-row type="flex" justify="center" :gutter="20">
        <el-col :span="13">
          <post-content
            class="mb-2"
            @updatePost="updatePost"
            @deletePost="deletePost"
            :callingAPI="callingAPI"
            :user="user"
            :post="post"
          />
        </el-col>
      </el-row>
    </el-container>
  </div>
</template>

<script>
import axios from 'axios';
import userServices from '../../services/users';
import ENDPOINT from '../../config/endpoint';
import { extractObject, extractArray } from '../../lib/common';
import PostContent from '../../components/posts/Content.vue';

export default {
  name: 'PostShow',
  components: {
    PostContent,
  },
  data() {
    return {
      callingAPI: true,
      post: null,
      user: null,
    };
  },
  beforeMount() {
    this.getPost();
  },
  methods: {
    updatePost(post) {
      this.post = post;
    },

    deletePost(id) {
      console.log(id);
      this.$router.push({ name: 'HomeScreen' });
    },

    getPost() {
      this.callingAPI = true;
      axios.get(`${ENDPOINT.POSTS}/${this.$route.params.id}?include=user,images`, {
        headers: {
          Authorization: `Bearer ${userServices.accessToken()}`,
        },
      })
        .then((res) => {
          this.post = res.data.data;
          const imageIds = this.post.relationships.images.data.map(image => image.id);
          this.user = extractObject(res.data.included, this.post.relationships.user.data.id, 'user');
          this.post.images = extractArray(res.data.included, imageIds, 'image');
          this.callingAPI = false;
        })
        .catch((err) => {
          this.callingAPI = false;
          const { response } = err;
          let message = '';
          switch (response.status) {
            case 404:
              message = 'Post not found';
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
  },
};
</script>
