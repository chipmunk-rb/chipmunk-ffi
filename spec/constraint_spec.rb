require File.dirname(__FILE__)+'/spec_helper'
describe 'Constraints in chipmunk' do
  describe 'PinJoint class' do    
    it 'can be created' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      CP::PinJoint.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2)
    end
    
    it 'can get its bodies' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      joint = CP::PinJoint.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2)
      joint.body_a.should be boda
      joint.body_b.should be bodb
    end
    
    it 'can set and get its max_force' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      joint = CP::PinJoint.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2)
      joint.max_force = 40
      joint.max_force.should == 40.0
    end
    
    it 'can set and get its max_bias' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      joint = CP::PinJoint.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2)
      joint.max_bias = 40
      joint.max_bias.should == 40.0
    end
    
    it 'can set and get its bias_coef' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      joint = CP::PinJoint.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2)
      joint.bias_coef = 40
      joint.bias_coef.should == 40.0
    end
    
    it 'can get and set its anchors' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      v1 = vec2(1,2)
      v2 = vec2(3,4)
      v3 = vec2(5,6)
      v4 = vec2(7,8)
      
      joint = CP::PinJoint.new(boda,bodb,v1,v2)
      joint.anchr1.should == v1
      joint.anchr2.should == v2

      joint.anchr1 = v3
      joint.anchr2 = v4
      joint.anchr1.should == v3
      joint.anchr2.should == v4
    end
    
    it 'can get and set its dist' do
      boda = CP::Body.new 90, 46
      bodb = CP::Body.new 9, 6
      joint = CP::PinJoint.new(boda,bodb,vec2(3,4),ZERO_VEC_2)
      joint.dist.should == 5.0
      joint.dist = 1
      joint.dist.should == 1.0
    end
    
  end

  describe 'SlideJoint class' do
    it 'can be created' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      CP::SlideJoint.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2,4,6)
    end
    
    it 'can get and set its anchors' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      v1 = vec2(1,2)
      v2 = vec2(3,4)
      v3 = vec2(5,6)
      v4 = vec2(7,8)
      
      joint = CP::SlideJoint.new(boda,bodb,v1,v2,4,6)
      joint.anchr1.should == v1
      joint.anchr2.should == v2

      joint.anchr1 = v3
      joint.anchr2 = v4
      joint.anchr1.should == v3
      joint.anchr2.should == v4
    end
    
    it 'can get and set its min and max' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      joint = CP::SlideJoint.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2,4,6)
      joint.min.should == 4
      joint.max.should == 6
      joint.min = 7
      joint.max = 8
      joint.min.should == 7
      joint.max.should == 8
    end
  end

  describe 'PivotJoint class' do
    it 'can be created' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      CP::PivotJoint.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2)
    end
    
    it 'can get and set its anchors' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      v1 = vec2(1,2)
      v2 = vec2(3,4)
      v3 = vec2(5,6)
      v4 = vec2(7,8)
      
      joint = CP::PivotJoint.new(boda,bodb,v1,v2)
      joint.anchr1.should == v1
      joint.anchr2.should == v2

      joint.anchr1 = v3
      joint.anchr2 = v4
      joint.anchr1.should == v3
      joint.anchr2.should == v4
    end
  end

  describe 'GrooveJoint class' do
    it 'can be created' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      CP::GrooveJoint.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2,ZERO_VEC_2)
    end
    
    it 'can get and set anchr2' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      v1 = vec2(1,2)
      v2 = vec2(3,4)
      joint = CP::GrooveJoint.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2,v1)
      joint.anchr2.should == v1
      joint.anchr2 = v2
      joint.anchr2.should == v2
    end
  end

  describe 'DampedSpring class' do
    it 'can be created' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      CP::DampedSpring.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2,3,4,5)
    end
    
    it 'can get and set its anchors' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      v1 = vec2(1,2)
      v2 = vec2(3,4)
      v3 = vec2(5,6)
      v4 = vec2(7,8)
      
      joint = CP::DampedSpring.new(boda,bodb,v1,v2,3,4,5)
      joint.anchr1.should == v1
      joint.anchr2.should == v2

      joint.anchr1 = v3
      joint.anchr2 = v4
      joint.anchr1.should == v3
      joint.anchr2.should == v4
    end
    
    it 'can get and set its rest length' do
      boda = CP::Body.new 90, 46
      bodb = CP::Body.new 9, 6
      joint = CP::DampedSpring.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2,3,4,5)
      joint.rest_length.should == 3.0
      joint.rest_length = 1
      joint.rest_length.should == 1.0
    end
    
    it 'can get and set its stiffness' do
      boda = CP::Body.new 90, 46
      bodb = CP::Body.new 9, 6
      joint = CP::DampedSpring.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2,3,4,5)
      joint.stiffness.should == 4.0
      joint.stiffness = 1
      joint.stiffness.should == 1.0
    end
    
    it 'can get and set its damping' do
      boda = CP::Body.new 90, 46
      bodb = CP::Body.new 9, 6
      joint = CP::DampedSpring.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2,3,4,5)
      joint.damping.should == 5.0
      joint.damping = 1
      joint.damping.should == 1.0
    end
    
    it 'can get and set its spring force function' do
      boda = CP::Body.new 90, 46
      bodb = CP::Body.new 9, 6
      joint = CP::DampedSpring.new(boda,bodb,ZERO_VEC_2,ZERO_VEC_2,3,4,5)
      joint.spring_force_func.call(joint.struct,1.0).should == 8.0
      joint.spring_force_func = lambda {|spring,float| float + 1.0 }
      joint.spring_force_func.call(joint.struct,1.0).should == 2.0
    end
  end

  describe 'RotaryLimitJoint class' do
    it 'can be created' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      CP::RotaryLimitJoint.new(boda,bodb,Math::PI,Math::PI/2)
    end
    
    it 'can get and set min and max' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      joint = CP::RotaryLimitJoint.new(boda,bodb,Math::PI,Math::PI/2)
      joint.min.should == Math::PI
      joint.max.should == Math::PI/2
      joint.min = 0
      joint.max = 1
      joint.min.should == 0
      joint.max.should == 1
    end
  end

  describe 'RatchetJoint class' do
    it 'can be created' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      CP::RatchetJoint.new(boda,bodb,3,4)
    end
    
    it 'can get and set its angle' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      joint = CP::RatchetJoint.new(boda,bodb,3,4)
      joint.angle.should == 0
      joint.angle = Math::PI/2
      joint.angle.should == Math::PI/2
    end
    
    it 'can get and set its phase' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      joint = CP::RatchetJoint.new(boda,bodb,3,4)
      joint.phase.should == 3.0
      joint.phase = 5.0
      joint.phase.should == 5.0
    end
    
    it 'can get and set its ratchet' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      joint = CP::RatchetJoint.new(boda,bodb,3,4)
      joint.ratchet.should == 4.0
      joint.ratchet = 6.0
      joint.ratchet.should == 6.0
    end
    
  end
  
  describe 'GearJoint class' do
    it 'can be created' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      CP::GearJoint.new(boda,bodb,1,2)
    end
    
    it 'can get and set its phase' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      joint = CP::GearJoint.new(boda,bodb,1,2)
      joint.phase.should == 1.0
      joint.phase = 5.0
      joint.phase.should == 5.0
    end
    
    it 'can get and set its ratio' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      joint = CP::GearJoint.new(boda,bodb,1,2)
      joint.ratio.should == 2.0
      joint.ratio = 6.0
      joint.ratio.should == 6.0
    end

  end

  describe 'SimpleMotor class' do
    it 'can be created' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      CP::SimpleMotor.new(boda,bodb,2)
    end
    
    it 'can get and set its rate' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      joint = CP::SimpleMotor.new(boda,bodb,2)
      joint.rate.should == 2.0
      joint.rate = -2.0
      joint.rate.should == -2.0
    end
  end
  
  describe 'DampedRotarySpring class' do
    it 'can be created' do
      boda = Body.new 90, 46
      bodb = Body.new 9, 6
      CP::DampedRotarySpring.new(boda,bodb,3,4,5)
    end
        
    it 'can get and set its rest angle' do
      boda = CP::Body.new 90, 46
      bodb = CP::Body.new 9, 6
      joint = CP::DampedRotarySpring.new(boda,bodb,3,4,5)
      joint.rest_angle.should == 3.0
      joint.rest_angle = 1
      joint.rest_angle.should == 1.0
    end
    
    it 'can get and set its stiffness' do
      boda = CP::Body.new 90, 46
      bodb = CP::Body.new 9, 6
      joint = CP::DampedRotarySpring.new(boda,bodb,3,4,5)
      joint.stiffness.should == 4.0
      joint.stiffness = 1
      joint.stiffness.should == 1.0
    end
    
    it 'can get and set its damping' do
      boda = CP::Body.new 90, 46
      bodb = CP::Body.new 9, 6
      joint = CP::DampedRotarySpring.new(boda,bodb,3,4,5)
      joint.damping.should == 5.0
      joint.damping = 1
      joint.damping.should == 1.0
    end
    
    it 'can get and set its spring torque function' do
      boda = CP::Body.new 90, 46
      bodb = CP::Body.new 9, 6
      joint = CP::DampedRotarySpring.new(boda,bodb,3,4,5)
      joint.spring_torque_func.call(joint.struct,1.0).should == -8.0
      joint.spring_torque_func = lambda {|spring,float| float + 1.0 }
      joint.spring_torque_func.call(joint.struct,1.0).should == 2.0
    end
  end
  
  
end
