import { Controller } from "@hotwired/stimulus"
import {transition, enter, leave} from "gaggle/el-transition"

export default class extends Controller {
  static targets = ['listener']
  static values = {
    open: Boolean,
    startAnimation: Boolean,
    skipHidden: Boolean
  }

  initialize() {
    this.startAnimationValue && this.update()
  }

  transitionClasses(element, animation, direction) {
    const animationClass = animation ? `${animation}-${direction}` : direction
    let transition = `transition${direction.charAt(0).toUpperCase() + direction.slice(1)}`
    const end = element.dataset[`${transition}End`] ? element.dataset[`${transition}End`].split(" ") : [`${animationClass}-end`]
    const final = element.dataset[`${transition}Final`] ? element.dataset[`${transition}Final`].split(" ") : [`${animationClass}-final`]
    return [end, final].flat()
  }

  removeLastTransition(element, animation, direction) {
    const classes = this.transitionClasses(element, animation, direction)
    removeClasses(element, classes)
  }

  async enter(element, transitionName = null) {
    let skipHidden = (this.skipHiddenValue || element.hasAttribute('data-transition-skip-hidden'))

    if (skipHidden) {
      this.removeLastTransition(element, transitionName, 'leave')
    } else {
      element.classList.remove('hidden')
    }
    this.element.dispatchEvent(new Event('toggler:enter-start'))

    await transition('enter', element, transitionName, skipHidden)
  }

  async leave(element, transitionName = null) {
    let skipHidden = (this.skipHiddenValue || element.hasAttribute('data-transition-skip-hidden'))

    if (skipHidden) {
      this.removeLastTransition(element, transitionName, 'enter')
    }
    this.element.dispatchEvent(new Event('toggler:leave-start'))
    await transition('leave', element, transitionName, skipHidden)
    !skipHidden && element.classList.add('hidden')
  }

  async toggle(element, transitionName = null) {
    if (this.openValue) {
      this.openValue = !this.openValue
      await enter(element, transitionName)
    } else {
      this.openValue = !this.openValue
      await leave(element, transitionName)
    }
  }

  toggle() {
    this.openValue = !this.openValue
    this.update()
  }

  close() {
    if (this.openValue) {
      this.openValue = false
      this.update()
    }
  }

  closeImmediately() {
    this.openValue = false
    this.listenerTargets.forEach((listener) => {
      this.removeLastTransition(listener, null, 'enter')
      const classes = this.transitionClasses(listener, null, 'leave')
      addClasses(listener, classes)
    })
  }

  open() {
    if (!this.openValue) {
      this.openValue = true
    }
    this.update()
  }

  update() {
    this.listenerTargets.forEach((listener) => {
      if (this.openValue) {
        this.enter(listener)
          .then(() => this.element.dispatchEvent(new Event('toggler:entered')))
      } else {
        this.leave(listener)
          .then(() => this.element.dispatchEvent(new Event('toggler:left')))
      }
    })
  }
}
