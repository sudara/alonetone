require 'test_helper'

class CommentsTest < ActionMailer::TestCase
  tests Comments
  def test_new_comment
    @expected.subject = 'Comments#new_comment'
    @expected.body    = read_fixture('new_comment')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Comments.create_new_comment(@expected.date).encoded
  end

end
