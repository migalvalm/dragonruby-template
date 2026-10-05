def test_splash_fades_in_and_out args, assert
  assert.equal! SplashScene.alpha(0), 0
  assert.equal! SplashScene.alpha(SplashScene::TICKS / 2), 255
  assert.equal! SplashScene.alpha(SplashScene::TICKS), 0
end
