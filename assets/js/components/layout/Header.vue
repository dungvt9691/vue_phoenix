<template>
  <div class="header">
    <el-container>
      <div class="header__items">
        <div class="header__items--item">
          <router-link :to="{name: 'HomeScreen'}">
            <img class="brand" src="/images/phoenix.png" alt="brand">
          </router-link>
        </div>
        <div class="header__items--item">
          <div class="profile">
            <div class="profile__avatar mr-1">
              <el-avatar
                v-if="profile.avatar.s50x50 === null"
                :size="35"
                src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png"
              ></el-avatar>
              <el-avatar
                v-else
                :size="35"
                :src="profile.avatar.s50x50"
              ></el-avatar>
            </div>
            <el-dropdown size="medium" trigger="click" class="profile__email">
              <span class="el-dropdown-link">
                {{ profile.full_name || profile.email }}<i class="ml-1 fas fa-caret-down"></i>
              </span>
              <el-dropdown-menu class="dropdown-profile" slot="dropdown">
                <el-dropdown-item>
                  <router-link :to="{name: 'ProfileScreen'}">
                    Profile
                  </router-link>
                </el-dropdown-item>
                <el-dropdown-item
                  class="text-danger"
                  divided
                >
                  <div @click="handleSignOut">
                    Sign out
                  </div>
                </el-dropdown-item>
              </el-dropdown-menu>
            </el-dropdown>
          </div>
        </div>
      </div>
    </el-container>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import axios from 'axios';
import userServices from '../../services/users';
import ENDPOINT from '../../config/endpoint';

export default {
  name: 'Header',
  computed: {
    ...mapGetters(['profile']),
  },
  methods: {
    ...mapActions(['updateAuthStatus']),
    handleSignOut() {
      const token = userServices.accessToken();
      userServices.signOut();
      this.$router.push({ name: 'SignInScreen' });
      axios.delete(ENDPOINT.AUTH, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
        .then(() => {
          this.updateAuthStatus(false);
        })
        .catch((err) => {
          this.updateAuthStatus(false);
          this.$notify.error({
            title: 'Error',
            message: err,
          });
        });
    },
  },
};
</script>

<style lang="scss" scoped>
.dropdown-profile{
  width: 200px;
  top: 47px !important;
  border-radius: 0;
  a{
    display: block;
    text-decoration: none;
    color: #333;
  }
}
</style>
