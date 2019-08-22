<template>
  <div class="comments" v-if="!callingAPI">
    <div class="comments--list">
      <div class="view-more" v-if="totalPages > 1 && currentPage !== totalPages">
        <el-button
          class="ml-1 btn-view-more"
          type="text"
          size="small"
          block
          :loading="callingAPI"
          @click="getComments(currentPage + 1)"
        >
          View more oldest comments
        </el-button>
      </div>
      <comment
        v-for="comment in comments"
        :key="comment.id"
        :comment="comment"
        @deleteComment="deleteComment"
        @updateComment="updateComment"
      />
    </div>
    <div class="comments--new">
      <el-avatar
        v-if="profile.avatar.s50x50 === null"
        :size="32"
        src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png"
      ></el-avatar>
      <el-avatar
        v-else
        :size="32"
        :src="profile.avatar.s50x50"
      ></el-avatar>
      <el-form
        class="ml-1"
        :model="addCommentForm"
        :inline="true"
        ref="addCommentForm"
      >
        <el-form-item :show-message="false" :inline="true">
          <el-input
            ref="content"
            type="textarea"
            :autosize="{ maxRows: 20}"
            placeholder="Leave a comment"
            size="small"
            :disabled="callingAddCommentAPI"
            v-model="addCommentForm.content"
            @keydown.enter.native.exact.prevent
            @keyup.enter.native.exact="submitForm"
          ></el-input>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import axios from 'axios';
import userServices from '../../services/users';
import ENDPOINT from '../../config/endpoint';
import { extractObject } from '../../lib/common';
import Comment from './Comment.vue';

export default {
  name: 'PostComments',
  props: ['post'],
  components: {
    Comment,
  },
  computed: {
    ...mapGetters(['profile']),
  },
  data() {
    return {
      callingAPI: true,
      callingAddCommentAPI: false,
      comments: [],
      currentPage: 1,
      limit: 10,
      totalPages: 1,
      addCommentForm: {
        content: '',
      },
    };
  },
  beforeMount() {
    this.getComments(this.currentPage);
  },
  methods: {
    addLine() {
      this.addCommentForm.content = `${this.addCommentForm.content}\n`;
    },

    deleteComment(id) {
      this.comments = this.comments.filter(comment => comment.id !== id);
    },

    updateComment(comment) {
      this.comments = this.comments.map((c) => {
        if (c.id === comment.id) {
          c.attributes.content = comment.attributes.content;
        }
        return c;
      });
    },

    getComments(page) {
      this.callingAPI = true;
      axios.get(`${ENDPOINT.POST_COMMENTS.replace(':post_id', this.post.id)}?include=user&page=${page}&limit=${this.limit}`, {
        headers: {
          Authorization: `Bearer ${userServices.accessToken()}`,
        },
      })
        .then((res) => {
          this.comments = res.data.data.reverse().map((comment) => {
            const data = comment;
            data.user = extractObject(res.data.included, comment.relationships.user.data.id, 'user');
            return data;
          }).concat(this.comments);
          this.totalPages = parseInt(res.headers['total-pages'], 0);
          this.currentPage = parseInt(res.headers['page-number'], 0);
          this.totalComments = parseInt(res.headers.total, 0);
          this.callingAPI = false;
        })
        .catch(() => {
          this.callingAPI = false;
          this.$notify.error({
            title: 'Error',
            message: 'Something went wrong',
          });
        });
    },

    submitForm() {
      const content = this.addCommentForm.content.replace(/\n/g, '');

      if (content === '') return false;

      this.$refs.addCommentForm.validate((valid) => {
        if (valid) {
          this.callingAddCommentAPI = true;
          axios.post(`${ENDPOINT.POST_COMMENTS.replace(':post_id', this.post.id)}?include=user`, {
            content: this.addCommentForm.content,
          }, {
            headers: {
              Authorization: `Bearer ${userServices.accessToken()}`,
            },
          })
            .then((res) => {
              const comment = res.data.data;
              comment.user = extractObject(res.data.included, comment.relationships.user.data.id, 'user');
              this.comments.push(comment);
              this.callingAddCommentAPI = false;
              this.addCommentForm.content = '';
              this.$nextTick(() => this.$refs.content.focus());
            })
            .catch((err) => {
              this.callingAddCommentAPI = false;
              this.$notify.error({
                title: 'Error',
                message: err,
              });
            });
        }
      });

      return true;
    },
  },
};
</script>
