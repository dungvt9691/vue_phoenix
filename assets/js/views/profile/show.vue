<template>
  <div class="profile-page">
    <el-container>
      <el-row :gutter="20">
        <el-col :span="11">
          <el-alert
            v-if="!profile.full_name || !profile.birthday"
            title="Please enter your missing information such as
                    first name, last name, birthday, etc."
            type="warning">
          </el-alert>
          <information :profile="profile"/>
        </el-col>
        <el-col :span="13">
          <uploaded-posts/>
        </el-col>
      </el-row>
    </el-container>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import Information from '../../components/profile/Information.vue';
import UploadedPosts from '../../components/profile/UploadedPosts.vue';

export default {
  name: 'ProfileShow',
  components: {
    Information,
    UploadedPosts,
  },
  computed: {
    ...mapGetters(['profile']),
  },
};
</script>
