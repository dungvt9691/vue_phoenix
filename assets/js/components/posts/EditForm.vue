<template>
  <el-form
    :model="editPostForm"
    ref="editPostForm"
    :rules="rules"
  >
    <el-form-item :error="errors.content" prop="content">
      <el-input
        ref="content"
        type="textarea"
        :autosize="{ minRows: 2, maxRows: 20}"
        size="small"
        :disabled="callingAPI"
        v-model="editPostForm.content"
        @keyup.esc.native="cancelEditPost"
      ></el-input>
    </el-form-item>
    <el-form-item>
      <el-button
        class="mt-1"
        type="primary"
        size="mini"
        @click="submitForm"
        :loading="callingAPI"
      >
        Done Editing
      </el-button>
      <el-button
        class="mt-1"
        type="default"
        size="mini"
        @click="cancelEditPost"
      >
        Cancel
      </el-button>
    </el-form-item>
  </el-form>
</template>

<script>
import { mapActions } from 'vuex';
import axios from 'axios';
import { extractObject, extractArray } from '../../lib/common';
import userServices from '../../services/users';
import ENDPOINT from '../../config/endpoint';

export default {
  name: 'EditPostForm',
  props: ['post'],
  data() {
    return {
      callingAPI: false,
      editPostForm: {
        content: this.post.attributes.content,
      },
      rules: {
        content: [
          { required: true, message: 'Please input content', trigger: 'blur' },
        ],
      },
      errors: {
        content: '',
      },
    };
  },
  beforeMount() {
    this.$nextTick(() => this.$refs.content.focus());
  },
  methods: {
    ...mapActions(['updateEditing']),

    cancelEditPost() {
      this.$emit('closeEditForm');
      setTimeout(() => {
        this.updateEditing(false);
      }, 100);
    },

    submitForm() {
      this.$refs.editPostForm.validate((valid) => {
        if (valid) {
          this.errors = {};
          const content = this.editPostForm.content.replace(/\n/g, '');

          if (content === '') {
            this.errors.content = 'Please input content';
            return false;
          }
          this.callingAPI = true;

          axios.put(`${ENDPOINT.POSTS}/${this.post.id}`, {
            content: this.editPostForm.content,
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
              this.$emit('updatePost', post);
              this.callingAPI = false;
              this.editPostForm.content = post.attributes.content;
              this.cancelEditPost();
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
  },
};
</script>

<style lang="scss" scoped>

</style>
