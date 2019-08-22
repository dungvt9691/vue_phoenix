<template>
  <div class="home-page">
    <el-container>
      <el-row type="flex" justify="center" :gutter="20">
        <el-col :span="13">
          <list-posts/>
        </el-col>
      </el-row>
    </el-container>
  </div>
</template>

<script>
import ListPosts from '../../components/posts/List.vue';

export default {
  name: 'SessionsNew',
  components: {
    ListPosts,
  },
};
</script>
