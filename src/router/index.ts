import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import store from '@/store'
import SignIn from '@/views/SignIn.vue'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'SignIn',
    component: SignIn,
  },
  {
    path: '/signup',
    name: 'EntrepriseAccount',
    component: () => import('@/views/EntrepriseAccount.vue'),
  },
  {
    path: '/account',
    name: 'Account',
    component: () => import('@/views/Account.vue'),
  },
  {
    path: '/create-project',
    name: 'createProject',
    component: () => import('@/views/CreateProject.vue'),
  },
  {
    path: '/fullrecap',
    name: 'FullRecap',
    component: () => import('@/views/FullRecap.vue'),
    props: false,
  },
  {
    path: '/open-bountie',
    name: 'OpenBountie',
    component: () => import('@/views/OpenBountie.vue'),
    props: false,
  },
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes,
})

router.beforeEach((to, _from, next) => {
  if (to.name !== 'SignIn' && !store.state.account.address) {
    next({ name: 'SignIn' })
  } else {
    next()
  }
})

export default router