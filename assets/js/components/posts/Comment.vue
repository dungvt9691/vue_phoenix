<template>
  <div class="comment">
    <div class="comment__user">
      <div class="comment__user--avatar mr-1">
        <el-avatar
          v-if="comment.user.attributes.avatar.s50x50 === null"
          :size="32"
          src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png"
        ></el-avatar>
        <el-avatar
          v-else
          :size="32"
          :src="comment.user.attributes.avatar.s50x50"
        ></el-avatar>
      </div>
      <div v-if="showEditForm" class="comment__editForm">
        <el-form
          :model="editCommentForm"
          :inline="true"
          ref="editCommentForm"
        >
          <el-form-item :show-message="false">
            <el-input
              ref="content"
              type="textarea"
              :autosize="{ maxRows: 20}"
              placeholder="Leave a comment"
              size="small"
              :disabled="callingEditCommentAPI"
              v-model="editCommentForm.content"
              @keydown.enter.native.exact.prevent
              @keyup.enter.native.exact="submitForm"
              @keyup.esc.native="cancelEditComment"
            ></el-input>
            <small class="hint">
              Press ESC to
              <el-button
                type="text"
                size="mini"
                block
                @click="cancelEditComment"
              >
                cancel
              </el-button>
            </small>
          </el-form-item>
        </el-form>
      </div>
      <div v-else class="comment__content">
        <div
          v-if="compact && comment.attributes.content.split(' ').length >= maxWords"
          class="content"
        >
          <strong class="name">
            {{ comment.user.attributes.full_name || comment.user.attributes.email }}
          </strong>
          <span v-html="compactContent.replace(/\n/g, '<br>')"></span>
          <span class="read-more" @click="compact = false">Read more</span>
        </div>
        <div v-else class="content">
          <strong class="name">
            {{ comment.user.attributes.full_name || comment.user.attributes.email }}
          </strong>
          <span v-html="comment.attributes.content.replace(/\n/g, '<br>')"></span>
        </div>
        <div class="created">
          {{ convertDateFromNow(comment.attributes.inserted_at) }}
        </div>
        <div
          v-if="profile.email === comment.user.attributes.email"
          :class="{'active': showActions}"
          class="comment__actions"
        >
          <el-dropdown
            @command="callAction"
            @visible-change="checkShowActions"
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
              <el-dropdown-item :icon="'el-icon-edit'" :command="'editComment'">
                Edit comment
              </el-dropdown-item>
              <el-dropdown-item :icon="'el-icon-delete'" :command="'deleteComment'">
                Delete comment
              </el-dropdown-item>
            </el-dropdown-menu>
          </el-dropdown>
        </div>
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

export default {
  name: 'Comment',
  props: ['comment'],
  computed: {
    ...mapGetters(['profile']),
    compactContent() {
      if (this.comment.attributes.content.split(' ').length >= this.maxWords) {
        return truncateContent(this.comment.attributes.content, this.maxWords);
      }
      return this.comment.attributes.content;
    },
  },
  data() {
    return {
      compact: true,
      callingEditCommentAPI: false,
      maxWords: 50,
      showActions: false,
      showEditForm: false,
      editCommentForm: {
        content: this.comment.attributes.content,
      },
    };
  },
  methods: {
    convertDateFromNow,

    ...mapActions(['updateEditing']),

    cancelEditComment() {
      this.showEditForm = false;
      setTimeout(() => {
        this.updateEditing(false);
      }, 100);
    },

    checkShowActions(value) {
      this.showActions = value;
    },

    callAction(command) {
      if (command === 'editComment') {
        this.showActions = false;
        this.showEditForm = true;
        this.$nextTick(() => this.$refs.content.focus());
        this.updateEditing(true);
      } else {
        this.deleteComment();
      }
    },

    submitForm() {
      const content = this.editCommentForm.content.replace(/\n/g, '');

      if (content === '') return false;

      this.$refs.editCommentForm.validate((valid) => {
        if (valid) {
          this.callingEditCommentAPI = true;
          axios.put(`${ENDPOINT.POST_COMMENTS.replace(':post_id', this.comment.attributes.post_id)}/${this.comment.id}`, {
            content: this.editCommentForm.content,
          }, {
            headers: {
              Authorization: `Bearer ${userServices.accessToken()}`,
            },
          })
            .then((res) => {
              const comment = res.data.data;
              this.$emit('updateComment', comment);
              this.callingEditCommentAPI = false;
              this.editCommentForm.content = comment.attributes.content;
              this.cancelEditComment();
            })
            .catch((err) => {
              this.callingEditCommentAPI = false;
              this.$notify.error({
                title: 'Error',
                message: err,
              });
            });
        }
      });

      return true;
    },

    deleteComment() {
      this.$confirm('Are you sure you want to delete this comment?', 'Warning', {
        confirmButtonText: 'OK',
        cancelButtonText: 'Cancel',
        type: 'warning',
      }).then(() => {
        axios.delete(`${ENDPOINT.POST_COMMENTS.replace(':post_id', this.comment.attributes.post_id)}/${this.comment.id}`, {
          headers: {
            Authorization: `Bearer ${userServices.accessToken()}`,
          },
        })
          .then(() => {
            this.$emit('deleteComment', this.comment.id);
          })
          .catch((err) => {
            const { response } = err;
            let message = '';
            switch (response.status) {
              case 404:
                message = 'Comment not found';
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

<style lang="scss" scoped>

</style>
